#!/usr/bin/env node
/**
 * Test script to verify Ghost API connection
 */

import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const GHOST_URL = process.env.GHOST_URL || 'https://commonplace.inquiry.institute';
const GHOST_ADMIN_API_KEY = process.env.GHOST_ADMIN_API_KEY;

if (!GHOST_ADMIN_API_KEY) {
  console.error('❌ ERROR: GHOST_ADMIN_API_KEY not set');
  console.error('   Set it in .env file or as environment variable');
  process.exit(1);
}

const GHOST_ADMIN_API_URL = `${GHOST_URL}/ghost/api/admin`;

console.log('Testing Ghost API connection...');
console.log(`URL: ${GHOST_ADMIN_API_URL}`);
console.log('');

async function testConnection() {
  try {
    const response = await axios.get(`${GHOST_ADMIN_API_URL}/site/`, {
      headers: {
        'Authorization': `Ghost ${GHOST_ADMIN_API_KEY}`,
      },
    });

    console.log('✅ Connection successful!');
    console.log('');
    console.log('Site information:');
    console.log(`  Title: ${response.data.site.title}`);
    console.log(`  URL: ${response.data.site.url}`);
    console.log(`  Version: ${response.data.site.version}`);
    console.log('');
    
    // Test users endpoint
    const usersResponse = await axios.get(`${GHOST_ADMIN_API_URL}/users/`, {
      headers: {
        'Authorization': `Ghost ${GHOST_ADMIN_API_KEY}`,
      },
      params: {
        limit: 5,
      },
    });
    
    console.log(`Users found: ${usersResponse.data.users?.length || 0}`);
    if (usersResponse.data.users?.length > 0) {
      console.log('Sample users:');
      usersResponse.data.users.slice(0, 3).forEach(user => {
        console.log(`  - ${user.name} (${user.email}) - ${user.roles?.[0]?.name || 'No role'}`);
      });
    }
    
    console.log('');
    console.log('✅ MCP Server is ready to use!');
    
  } catch (error) {
    console.error('❌ Connection failed!');
    console.error('');
    if (error.response) {
      console.error(`Status: ${error.response.status}`);
      console.error(`Error: ${JSON.stringify(error.response.data, null, 2)}`);
    } else {
      console.error(`Error: ${error.message}`);
    }
    console.error('');
    console.error('Troubleshooting:');
    console.error('  1. Verify GHOST_ADMIN_API_KEY is correct');
    console.error('  2. Check that Ghost is accessible at:', GHOST_URL);
    console.error('  3. Ensure the API key hasn\'t been revoked');
    process.exit(1);
  }
}

testConnection();
