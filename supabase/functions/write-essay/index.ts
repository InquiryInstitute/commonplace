/**
 * Supabase Edge Function: Write Essay in Faculty Persona
 * 
 * Generates essays in the style/persona of specific faculty members
 * using AI/LLM capabilities.
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENROUTER_API_KEY = Deno.env.get('OPENROUTER_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

interface EssayRequest {
  faculty_name: string
  faculty_lastname: string
  topic: string
  format?: 'essay' | 'salon' | 'review' | 'dialogue'
  length?: 'short' | 'medium' | 'long'
  style_notes?: string
  additional_context?: string
}

interface FacultyPersona {
  name: string
  lastname: string
  style: string
  themes: string[]
  writing_characteristics: string[]
}

// Faculty persona database (could be moved to Supabase table)
const FACULTY_PERSONAS: Record<string, FacultyPersona> = {
  'arendt': {
    name: 'Hannah',
    lastname: 'Arendt',
    style: 'Philosophical, analytical, concerned with political theory and human condition',
    themes: ['politics', 'totalitarianism', 'freedom', 'action', 'thinking'],
    writing_characteristics: [
      'Dense philosophical prose',
      'Historical analysis',
      'Conceptual clarity',
      'Engagement with classical texts',
      'Focus on human agency and responsibility'
    ]
  },
  'marx': {
    name: 'Karl',
    lastname: 'Marx',
    style: 'Critical, dialectical, materialist analysis',
    themes: ['capitalism', 'class struggle', 'alienation', 'history', 'economics'],
    writing_characteristics: [
      'Historical materialism',
      'Critical analysis of social structures',
      'Engagement with political economy',
      'Revolutionary perspective',
      'Systematic critique'
    ]
  },
  'austen': {
    name: 'Jane',
    lastname: 'Austen',
    style: 'Witty, observant, social commentary through narrative',
    themes: ['society', 'marriage', 'class', 'morality', 'women'],
    writing_characteristics: [
      'Irony and wit',
      'Social observation',
      'Character development',
      'Moral complexity',
      'Narrative precision'
    ]
  },
  // Add more faculty personas as needed
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    const requestData: EssayRequest = await req.json()

    // Validate required fields
    if (!requestData.faculty_lastname || !requestData.topic) {
      return new Response(
        JSON.stringify({ error: 'faculty_lastname and topic are required' }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        }
      )
    }

    const facultyKey = requestData.faculty_lastname.toLowerCase()
    const persona = FACULTY_PERSONAS[facultyKey]

    if (!persona) {
      return new Response(
        JSON.stringify({ 
          error: `Faculty persona not found for ${requestData.faculty_lastname}`,
          available_faculty: Object.keys(FACULTY_PERSONAS)
        }),
        {
          status: 404,
          headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        }
      )
    }

    // Build prompt for AI
    const format = requestData.format || 'essay'
    const length = requestData.length || 'medium'
    const lengthWords = length === 'short' ? '500-800' : length === 'medium' ? '1000-1500' : '2000-3000'

    const prompt = `Write a ${format} in the style and persona of ${persona.name} ${persona.lastname}.

Topic: ${requestData.topic}

${requestData.additional_context ? `Additional context: ${requestData.additional_context}\n` : ''}

Writing style characteristics:
${persona.writing_characteristics.map(c => `- ${c}`).join('\n')}

Themes and concerns: ${persona.themes.join(', ')}

Style notes: ${persona.style}
${requestData.style_notes ? `\nAdditional style notes: ${requestData.style_notes}` : ''}

Requirements:
- Length: ${lengthWords} words
- Format: ${format}
- Write in the first person as ${persona.name} ${persona.lastname}
- Maintain their distinctive voice, concerns, and intellectual approach
- Engage with the topic in a way that reflects their philosophical/political/literary perspective
- Use their characteristic writing style and terminology

Generate the ${format} now:`

    // Call OpenRouter API
    if (!OPENROUTER_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'OPENROUTER_API_KEY not configured' }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        }
      )
    }

    // Use a high-quality model via OpenRouter (default to Claude Sonnet or GPT-4)
    const model = 'anthropic/claude-3.5-sonnet' // or 'openai/gpt-4-turbo'

    const openrouterResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://commonplace.inquiry.institute', // Optional: for analytics
        'X-Title': 'Commonplace Essay Generator', // Optional: for analytics
      },
      body: JSON.stringify({
        model: model,
        messages: [
          {
            role: 'system',
            content: `You are an expert at writing in the style of historical and contemporary thinkers. 
            You can accurately capture their voice, concerns, and intellectual approach. 
            Write essays, dialogues, reviews, and salon pieces that authentically reflect their perspectives.`
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: length === 'short' ? 1000 : length === 'medium' ? 2000 : 4000,
      }),
    })

    if (!openrouterResponse.ok) {
      const error = await openrouterResponse.text()
      return new Response(
        JSON.stringify({ error: 'OpenRouter API error', details: error }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        }
      )
    }

    const openrouterData = await openrouterResponse.json()
    const essayContent = openrouterData.choices[0]?.message?.content || ''

    // Extract title if present, or generate one
    const titleMatch = essayContent.match(/^#\s+(.+)$/m) || essayContent.match(/^Title:\s*(.+)$/mi)
    const title = titleMatch ? titleMatch[1].trim() : `${requestData.topic}: A ${format} by ${persona.name} ${persona.lastname}`
    
    // Clean up content (remove title if it was extracted)
    let cleanContent = essayContent
    if (titleMatch) {
      cleanContent = essayContent.replace(/^#\s+.+$/m, '').trim()
    }

    // Return response
    return new Response(
      JSON.stringify({
        success: true,
        essay: {
          title,
          content: cleanContent,
          faculty: {
            name: persona.name,
            lastname: persona.lastname,
            full_name: `${persona.name} ${persona.lastname}`
          },
          format,
          length,
          topic: requestData.topic,
          word_count: cleanContent.split(/\s+/).length,
        },
        metadata: {
          persona_used: persona,
          generated_at: new Date().toISOString(),
        }
      }),
      {
        status: 200,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        message: error.message,
        stack: error.stack 
      }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      }
    )
  }
})
