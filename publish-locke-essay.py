#!/usr/bin/env python3
"""
Publish Locke essay to Ghost
"""

import json
import sys
import os
import requests

GHOST_URL = "https://commonplace.inquiry.institute"
ESSAY_FILE = "locke-essay-response.json"

def main():
    # Load essay
    with open(ESSAY_FILE, 'r') as f:
        data = json.load(f)
    
    essay = data['essay']
    
    # Get API key
    api_key = os.environ.get('GHOST_ADMIN_API_KEY')
    if not api_key:
        print("Set GHOST_ADMIN_API_KEY environment variable or enter it:")
        api_key = input("Ghost Admin API Key: ").strip()
    
    if not api_key:
        print("❌ API key required")
        sys.exit(1)
    
    api_base = f"{GHOST_URL}/ghost/api/admin"
    headers = {
        "Authorization": f"Ghost {api_key}",
        "Content-Type": "application/json"
    }
    
    # Get first admin user as author
    print("Getting author...")
    users_resp = requests.get(
        f"{api_base}/users/?filter=roles:Administrator&limit=1",
        headers=headers
    )
    users_data = users_resp.json()
    if not users_data.get('users'):
        print("❌ No admin user found")
        sys.exit(1)
    
    author = users_data['users'][0]
    author_id = author['id']
    print(f"Author: {author['name']} ({author['email']})")
    
    # Get or create tags
    print("Setting up tags...")
    
    # faculty-locke tag
    tags_resp = requests.get(
        f"{api_base}/tags/?filter=slug:faculty-locke",
        headers=headers
    )
    tags_data = tags_resp.json()
    faculty_locke_id = tags_data['tags'][0]['id'] if tags_data.get('tags') else None
    
    if not faculty_locke_id:
        print("Creating faculty-locke tag...")
        create_tag_resp = requests.post(
            f"{api_base}/tags/",
            headers=headers,
            json={
                "tags": [{
                    "name": "John Locke",
                    "slug": "faculty-locke",
                    "description": "Content by John Locke",
                    "visibility": "public"
                }]
            }
        )
        create_data = create_tag_resp.json()
        faculty_locke_id = create_data['tags'][0]['id'] if create_data.get('tags') else None
    
    # Essay tag
    essay_tag_resp = requests.get(
        f"{api_base}/tags/?filter=slug:essay",
        headers=headers
    )
    essay_tag_data = essay_tag_resp.json()
    essay_tag_id = essay_tag_data['tags'][0]['id'] if essay_tag_data.get('tags') else None
    
    # Build tags array
    tag_ids = [{"id": faculty_locke_id}] if faculty_locke_id else []
    if essay_tag_id:
        tag_ids.append({"id": essay_tag_id})
    
    # Publish post
    print("Publishing essay...")
    post_data = {
        "posts": [{
            "title": essay['title'],
            "html": essay['content'],
            "status": "draft",
            "authors": [{"id": author_id}],
            "tags": tag_ids
        }]
    }
    
    publish_resp = requests.post(
        f"{api_base}/posts/",
        headers=headers,
        json=post_data
    )
    
    if publish_resp.status_code == 201 or publish_resp.status_code == 200:
        post = publish_resp.json()['posts'][0]
        print("\n✅ Essay published successfully!")
        print(f"Post ID: {post['id']}")
        print(f"Slug: {post['slug']}")
        print(f"URL: {post['url']}")
        print(f"Status: {post['status']}")
        print(f"\nView in Ghost admin: {GHOST_URL}/ghost/#/posts/{post['id']}")
    else:
        print(f"❌ Failed to publish: {publish_resp.status_code}")
        print(publish_resp.text)
        sys.exit(1)

if __name__ == "__main__":
    main()
