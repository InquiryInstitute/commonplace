#!/usr/bin/env node

/**
 * Commonplace Ghost MCP Server
 * 
 * Provides MCP tools for Ghost CMS operations:
 * - Create faculty accounts
 * - Publish essays
 * - Review essays
 * - List essays
 * - Manage content
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const GHOST_URL = process.env.GHOST_URL || 'https://commonplace.inquiry.institute';
const GHOST_ADMIN_API_KEY = process.env.GHOST_ADMIN_API_KEY || '';
const GHOST_ADMIN_API_URL = `${GHOST_URL}/ghost/api/admin`;

// Create Ghost API client
const ghostClient = axios.create({
  baseURL: GHOST_ADMIN_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Helper function to make authenticated Ghost API requests
async function ghostRequest(method, endpoint, data = null) {
  try {
    const url = endpoint.startsWith('http') ? endpoint : `${GHOST_ADMIN_API_URL}${endpoint}`;
    const config = {
      method,
      url,
      headers: {
        'Authorization': `Ghost ${GHOST_ADMIN_API_KEY}`,
      },
    };
    
    if (data) {
      config.data = data;
    }
    
    const response = await axios(config);
    return { success: true, data: response.data };
  } catch (error) {
    return {
      success: false,
      error: error.response?.data?.errors?.[0]?.message || error.message,
      details: error.response?.data,
    };
  }
}

// Initialize MCP Server
const server = new Server(
  {
    name: 'commonplace-ghost-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'create_faculty_account',
        description: 'Create a new faculty account in Ghost. Returns the created user with API key.',
        inputSchema: {
          type: 'object',
          properties: {
            name: {
              type: 'string',
              description: 'Full name of the faculty member',
            },
            email: {
              type: 'string',
              description: 'Email address for the faculty account',
            },
            role: {
              type: 'string',
              enum: ['Administrator', 'Editor', 'Author', 'Contributor'],
              description: 'Role for the faculty member (default: Author)',
              default: 'Author',
            },
            send_invite: {
              type: 'boolean',
              description: 'Whether to send an invitation email (default: true)',
              default: true,
            },
          },
          required: ['name', 'email'],
        },
      },
      {
        name: 'publish_essay',
        description: 'Publish a new essay/post to Ghost. Can be published immediately or saved as draft.',
        inputSchema: {
          type: 'object',
          properties: {
            title: {
              type: 'string',
              description: 'Title of the essay',
            },
            content: {
              type: 'string',
              description: 'HTML or Markdown content of the essay',
            },
            author_email: {
              type: 'string',
              description: 'Email of the author (must be existing Ghost user)',
            },
            status: {
              type: 'string',
              enum: ['draft', 'published', 'scheduled'],
              description: 'Publication status (default: draft)',
              default: 'draft',
            },
            tags: {
              type: 'array',
              items: { type: 'string' },
              description: 'Array of tag names to apply to the essay',
            },
            excerpt: {
              type: 'string',
              description: 'Short excerpt/summary of the essay',
            },
            featured: {
              type: 'boolean',
              description: 'Whether to feature this essay (default: false)',
              default: false,
            },
            published_at: {
              type: 'string',
              description: 'ISO 8601 date for scheduled publishing (required if status=scheduled)',
            },
          },
          required: ['title', 'content', 'author_email'],
        },
      },
      {
        name: 'review_essay',
        description: 'Review an essay - update status, add comments, or modify content. Can approve for publication.',
        inputSchema: {
          type: 'object',
          properties: {
            post_id: {
              type: 'string',
              description: 'ID of the post/essay to review',
            },
            action: {
              type: 'string',
              enum: ['approve', 'reject', 'request_revision', 'update'],
              description: 'Review action to take',
            },
            comment: {
              type: 'string',
              description: 'Review comment or feedback',
            },
            status: {
              type: 'string',
              enum: ['draft', 'published'],
              description: 'New status (for approve/update actions)',
            },
            content_updates: {
              type: 'object',
              description: 'Partial content updates (title, excerpt, tags, etc.)',
            },
          },
          required: ['post_id', 'action'],
        },
      },
      {
        name: 'list_essays',
        description: 'List essays/posts with optional filtering by author, status, tags, or date range.',
        inputSchema: {
          type: 'object',
          properties: {
            author_email: {
              type: 'string',
              description: 'Filter by author email',
            },
            status: {
              type: 'string',
              enum: ['all', 'draft', 'published', 'scheduled'],
              description: 'Filter by publication status (default: all)',
              default: 'all',
            },
            tag: {
              type: 'string',
              description: 'Filter by tag name',
            },
            limit: {
              type: 'number',
              description: 'Maximum number of results (default: 15, max: 100)',
              default: 15,
            },
            page: {
              type: 'number',
              description: 'Page number for pagination (default: 1)',
              default: 1,
            },
            order: {
              type: 'string',
              enum: ['published_at DESC', 'published_at ASC', 'created_at DESC', 'created_at ASC', 'title ASC', 'title DESC'],
              description: 'Sort order (default: published_at DESC)',
              default: 'published_at DESC',
            },
          },
        },
      },
      {
        name: 'get_essay',
        description: 'Get details of a specific essay/post by ID or slug.',
        inputSchema: {
          type: 'object',
          properties: {
            post_id: {
              type: 'string',
              description: 'Post ID',
            },
            slug: {
              type: 'string',
              description: 'Post slug (alternative to post_id)',
            },
            include: {
              type: 'array',
              items: { type: 'string' },
              description: 'Additional data to include (authors, tags, etc.)',
            },
          },
        },
      },
      {
        name: 'update_essay',
        description: 'Update an existing essay/post. Can modify title, content, status, tags, etc.',
        inputSchema: {
          type: 'object',
          properties: {
            post_id: {
              type: 'string',
              description: 'ID of the post to update',
            },
            title: {
              type: 'string',
              description: 'New title',
            },
            content: {
              type: 'string',
              description: 'Updated content (HTML or Markdown)',
            },
            status: {
              type: 'string',
              enum: ['draft', 'published', 'scheduled'],
              description: 'New publication status',
            },
            tags: {
              type: 'array',
              items: { type: 'string' },
              description: 'Updated tags',
            },
            excerpt: {
              type: 'string',
              description: 'Updated excerpt',
            },
            featured: {
              type: 'boolean',
              description: 'Featured status',
            },
          },
          required: ['post_id'],
        },
      },
      {
        name: 'delete_essay',
        description: 'Delete an essay/post. Use with caution - this action cannot be undone.',
        inputSchema: {
          type: 'object',
          properties: {
            post_id: {
              type: 'string',
              description: 'ID of the post to delete',
            },
          },
          required: ['post_id'],
        },
      },
      {
        name: 'list_faculty',
        description: 'List all faculty members (Ghost users) with their roles and status.',
        inputSchema: {
          type: 'object',
          properties: {
            role: {
              type: 'string',
              enum: ['all', 'Administrator', 'Editor', 'Author', 'Contributor'],
              description: 'Filter by role (default: all)',
              default: 'all',
            },
            status: {
              type: 'string',
              enum: ['all', 'active', 'inactive', 'locked'],
              description: 'Filter by status (default: all)',
              default: 'all',
            },
            limit: {
              type: 'number',
              description: 'Maximum number of results (default: 15)',
              default: 15,
            },
          },
        },
      },
      {
        name: 'get_faculty',
        description: 'Get details of a specific faculty member by email or ID.',
        inputSchema: {
          type: 'object',
          properties: {
            email: {
              type: 'string',
              description: 'Email address of the faculty member',
            },
            user_id: {
              type: 'string',
              description: 'User ID (alternative to email)',
            },
          },
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'create_faculty_account': {
        const { name: userName, email, role = 'Author', send_invite = true } = args;
        
        // First, check if user already exists
        const checkResult = await ghostRequest('GET', `/users/?filter=email:'${email}'`);
        if (checkResult.success && checkResult.data?.users?.length > 0) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  error: 'User already exists',
                  user: checkResult.data.users[0],
                }, null, 2),
              },
            ],
          };
        }

        // Create invitation or user
        const endpoint = send_invite ? '/users/invite/' : '/users/';
        const payload = {
          users: [{
            name: userName,
            email: email,
            roles: [role],
          }],
        };

        if (send_invite) {
          payload.invitation = {
            email: email,
            role: role,
          };
        }

        const result = await ghostRequest('POST', endpoint, payload);
        
        if (!result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({ error: result.error, details: result.details }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const user = result.data?.users?.[0] || result.data?.invitations?.[0];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                message: send_invite ? 'Invitation sent' : 'User created',
                user: {
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  role: user.roles?.[0]?.name || role,
                  status: user.status,
                },
              }, null, 2),
            },
          ],
        };
      }

      case 'publish_essay': {
        const {
          title,
          content,
          author_email,
          status = 'draft',
          tags = [],
          excerpt,
          featured = false,
          published_at,
        } = args;

        // Get author ID
        const authorResult = await ghostRequest('GET', `/users/?filter=email:'${author_email}'`);
        if (!authorResult.success || !authorResult.data?.users?.length) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  error: 'Author not found',
                  message: `No user found with email: ${author_email}`,
                }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const author = authorResult.data.users[0];

        // Resolve tags if provided
        let tagIds = [];
        if (tags.length > 0) {
          const tagsResult = await ghostRequest('GET', '/tags/');
          if (tagsResult.success) {
            const existingTags = tagsResult.data.tags || [];
            for (const tagName of tags) {
              let tag = existingTags.find(t => t.name.toLowerCase() === tagName.toLowerCase());
              if (!tag) {
                // Create tag if it doesn't exist
                const createTagResult = await ghostRequest('POST', '/tags/', {
                  tags: [{ name: tagName }],
                });
                if (createTagResult.success) {
                  tag = createTagResult.data.tags[0];
                }
              }
              if (tag) {
                tagIds.push(tag.id);
              }
            }
          }
        }

        // Create post
        const postData = {
          posts: [{
            title,
            html: content,
            status,
            authors: [{ id: author.id }],
            tags: tagIds.map(id => ({ id })),
            excerpt,
            featured,
          }],
        };

        if (status === 'scheduled' && published_at) {
          postData.posts[0].published_at = published_at;
        }

        const result = await ghostRequest('POST', '/posts/', postData);

        if (!result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({ error: result.error, details: result.details }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const post = result.data.posts[0];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                message: `Essay ${status === 'published' ? 'published' : 'created as draft'}`,
                post: {
                  id: post.id,
                  title: post.title,
                  slug: post.slug,
                  status: post.status,
                  url: post.url,
                  created_at: post.created_at,
                  published_at: post.published_at,
                },
              }, null, 2),
            },
          ],
        };
      }

      case 'review_essay': {
        const { post_id, action, comment, status, content_updates } = args;

        // Get current post
        const getResult = await ghostRequest('GET', `/posts/${post_id}/`);
        if (!getResult.success || !getResult.data?.posts?.length) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  error: 'Post not found',
                  message: `No post found with ID: ${post_id}`,
                }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const currentPost = getResult.data.posts[0];
        let updateData = { posts: [{ id: post_id }] };

        switch (action) {
          case 'approve':
            if (status) {
              updateData.posts[0].status = status;
            } else {
              updateData.posts[0].status = 'published';
            }
            if (comment) {
              // Store comment in custom excerpt or note field
              updateData.posts[0].custom_excerpt = comment;
            }
            break;

          case 'reject':
            updateData.posts[0].status = 'draft';
            if (comment) {
              updateData.posts[0].custom_excerpt = `REJECTED: ${comment}`;
            }
            break;

          case 'request_revision':
            updateData.posts[0].status = 'draft';
            if (comment) {
              updateData.posts[0].custom_excerpt = `REVISION REQUESTED: ${comment}`;
            }
            break;

          case 'update':
            if (status) updateData.posts[0].status = status;
            if (content_updates) {
              Object.assign(updateData.posts[0], content_updates);
            }
            if (comment) {
              updateData.posts[0].custom_excerpt = comment;
            }
            break;
        }

        const result = await ghostRequest('PUT', `/posts/${post_id}/`, updateData);

        if (!result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({ error: result.error, details: result.details }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const updatedPost = result.data.posts[0];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                message: `Essay ${action} completed`,
                action,
                comment,
                post: {
                  id: updatedPost.id,
                  title: updatedPost.title,
                  status: updatedPost.status,
                  url: updatedPost.url,
                },
              }, null, 2),
            },
          ],
        };
      }

      case 'list_essays': {
        const {
          author_email,
          status = 'all',
          tag,
          limit = 15,
          page = 1,
          order = 'published_at DESC',
        } = args;

        let filter = '';
        if (author_email) {
          filter += `authors.email:'${author_email}'`;
        }
        if (status !== 'all') {
          if (filter) filter += '+';
          filter += `status:${status}`;
        }
        if (tag) {
          if (filter) filter += '+';
          filter += `tag:${tag}`;
        }

        const params = new URLSearchParams({
          limit: limit.toString(),
          page: page.toString(),
          order: order,
        });
        if (filter) {
          params.append('filter', filter);
        }

        const result = await ghostRequest('GET', `/posts/?${params.toString()}`);

        if (!result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({ error: result.error, details: result.details }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const posts = result.data.posts || [];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                count: posts.length,
                meta: result.data.meta,
                posts: posts.map(post => ({
                  id: post.id,
                  title: post.title,
                  slug: post.slug,
                  status: post.status,
                  url: post.url,
                  excerpt: post.excerpt,
                  published_at: post.published_at,
                  created_at: post.created_at,
                  authors: post.authors?.map(a => ({ name: a.name, email: a.email })),
                  tags: post.tags?.map(t => t.name),
                })),
              }, null, 2),
            },
          ],
        };
      }

      case 'get_essay': {
        const { post_id, slug, include = [] } = args;

        if (!post_id && !slug) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  error: 'Missing parameter',
                  message: 'Either post_id or slug must be provided',
                }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const endpoint = post_id ? `/posts/${post_id}/` : `/posts/slug/${slug}/`;
        const params = include.length > 0 ? `?include=${include.join(',')}` : '';
        const result = await ghostRequest('GET', `${endpoint}${params}`);

        if (!result.success || !result.data?.posts?.length) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  error: 'Post not found',
                  message: result.error || 'Post not found',
                }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const post = result.data.posts[0];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                post: {
                  id: post.id,
                  title: post.title,
                  slug: post.slug,
                  html: post.html,
                  status: post.status,
                  url: post.url,
                  excerpt: post.excerpt,
                  featured: post.featured,
                  published_at: post.published_at,
                  created_at: post.created_at,
                  updated_at: post.updated_at,
                  authors: post.authors?.map(a => ({
                    id: a.id,
                    name: a.name,
                    email: a.email,
                  })),
                  tags: post.tags?.map(t => ({
                    id: t.id,
                    name: t.name,
                    slug: t.slug,
                  })),
                },
              }, null, 2),
            },
          ],
        };
      }

      case 'update_essay': {
        const { post_id, ...updates } = args;

        const updateData = {
          posts: [{
            id: post_id,
            ...updates,
          }],
        };

        const result = await ghostRequest('PUT', `/posts/${post_id}/`, updateData);

        if (!result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({ error: result.error, details: result.details }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const updatedPost = result.data.posts[0];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                message: 'Essay updated successfully',
                post: {
                  id: updatedPost.id,
                  title: updatedPost.title,
                  status: updatedPost.status,
                  url: updatedPost.url,
                  updated_at: updatedPost.updated_at,
                },
              }, null, 2),
            },
          ],
        };
      }

      case 'delete_essay': {
        const { post_id } = args;

        const result = await ghostRequest('DELETE', `/posts/${post_id}/`);

        if (!result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({ error: result.error, details: result.details }, null, 2),
              },
            ],
            isError: true,
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                message: 'Essay deleted successfully',
                post_id,
              }, null, 2),
            },
          ],
        };
      }

      case 'list_faculty': {
        const { role = 'all', status = 'all', limit = 15 } = args;

        let filter = '';
        if (role !== 'all') {
          filter += `roles:${role}`;
        }
        if (status !== 'all') {
          if (filter) filter += '+';
          filter += `status:${status}`;
        }

        const params = new URLSearchParams({
          limit: limit.toString(),
        });
        if (filter) {
          params.append('filter', filter);
        }

        const result = await ghostRequest('GET', `/users/?${params.toString()}`);

        if (!result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({ error: result.error, details: result.details }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const users = result.data.users || [];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                count: users.length,
                faculty: users.map(user => ({
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  role: user.roles?.[0]?.name,
                  status: user.status,
                  last_seen: user.last_seen,
                  created_at: user.created_at,
                })),
              }, null, 2),
            },
          ],
        };
      }

      case 'get_faculty': {
        const { email, user_id } = args;

        if (!email && !user_id) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  error: 'Missing parameter',
                  message: 'Either email or user_id must be provided',
                }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const filter = email ? `email:'${email}'` : `id:${user_id}`;
        const result = await ghostRequest('GET', `/users/?filter=${filter}`);

        if (!result.success || !result.data?.users?.length) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  error: 'User not found',
                  message: result.error || 'User not found',
                }, null, 2),
              },
            ],
            isError: true,
          };
        }

        const user = result.data.users[0];
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                faculty: {
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  role: user.roles?.[0]?.name,
                  status: user.status,
                  last_seen: user.last_seen,
                  created_at: user.created_at,
                  bio: user.bio,
                  location: user.location,
                  website: user.website,
                },
              }, null, 2),
            },
          ],
        };
      }

      default:
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                error: 'Unknown tool',
                message: `Tool '${name}' is not recognized`,
              }, null, 2),
            },
          ],
          isError: true,
        };
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            error: 'Internal error',
            message: error.message,
            stack: error.stack,
          }, null, 2),
        },
      ],
      isError: true,
    };
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Commonplace Ghost MCP Server running on stdio');
}

main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
