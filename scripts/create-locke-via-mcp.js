#!/usr/bin/env node
/**
 * Create Locke persona account using MCP server code
 */

import axios from 'axios';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load env
dotenv.config({ path: join(__dirname, '..', 'mcp-server', '.env') });

const GHOST_URL = process.env.GHOST_URL || 'https://commonplace.inquiry.institute';
const GHOST_ADMIN_API_KEY = process.env.GHOST_ADMIN_API_KEY || '';

if (!GHOST_ADMIN_API_KEY) {
  console.error('❌ GHOST_ADMIN_API_KEY not set in mcp-server/.env');
  console.error('Get it from: Ghost Admin → Settings → Integrations');
  process.exit(1);
}

const API_BASE = `${GHOST_URL}/ghost/api/admin`;

async function createLockeAccount() {
  try {
    console.log('Creating John Locke persona account...\n');
    
    const email = 'a.locke@inquiry.institute';
    const name = 'John Locke';
    const bio = 'Empiricist philosopher. Content generated in the persona of John Locke using AI.';
    
    // Check if exists
    const checkResp = await axios.get(
      `${API_BASE}/users/?filter=email:'${email}'`,
      { headers: { 'Authorization': `Ghost ${GHOST_ADMIN_API_KEY}` } }
    );
    
    if (checkResp.data.users && checkResp.data.users.length > 0) {
      console.log('✅ Account already exists:');
      const user = checkResp.data.users[0];
      console.log(`   ID: ${user.id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Name: ${user.name}`);
      console.log(`   Role: ${user.roles?.[0]?.name}`);
      return;
    }
    
    // Create account
    const createResp = await axios.post(
      `${API_BASE}/users/`,
      {
        users: [{
          name,
          email,
          roles: ['Author'],
          bio,
          status: 'active',
        }],
      },
      { headers: { 'Authorization': `Ghost ${GHOST_ADMIN_API_KEY}`, 'Content-Type': 'application/json' } }
    );
    
    if (createResp.data.users && createResp.data.users.length > 0) {
      const user = createResp.data.users[0];
      console.log('✅ Account created successfully!');
      console.log(`   ID: ${user.id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Name: ${user.name}`);
      console.log(`   Role: ${user.roles?.[0]?.name}`);
      console.log(`\n   This account can now publish essays and comment.`);
    } else {
      console.error('❌ Failed to create account');
      console.error(createResp.data);
    }
  } catch (error) {
    if (error.response?.data?.errors) {
      const errMsg = error.response.data.errors[0]?.message || 'Unknown error';
      if (errMsg.includes('already exists') || errMsg.includes('User already exists')) {
        console.log('✅ Account already exists');
      } else {
        console.error('❌ Error:', errMsg);
        console.error(error.response.data);
      }
    } else {
      console.error('❌ Error:', error.message);
    }
    process.exit(1);
  }
}

createLockeAccount();
