# Fix AI Chat by using correct environment variable access

## Problem
The AI chat always fails with "Toolkit URL not configured" because the code reads environment variables the wrong way. It tries to read from system-level sources that don't exist in this app, instead of using the built-in configuration that's injected at build time.

## What Will Change

**Fix environment variable access**
- Switch from the broken custom method to the app's built-in configuration system
- This includes the Toolkit URL, Project ID, Team ID, and App Key

**Verify & fix the API request format**
- Ensure the message format sent to the AI matches what the server expects (Vercel AI v5 format)
- Ensure tool definitions use the correct schema format
- Add proper error logging so if something still goes wrong, the error message is actually helpful

## What Won't Change
- The chat UI stays exactly as-is
- The streaming SSE approach stays (it's correct)
- The tool calling / listing search logic stays
- Thread management, message history, all untouched

## Expected Result
When you type a message in Ask Redfin, it should connect to the AI service, stream a response, and support searching listings via tool calls — instead of immediately showing an error.