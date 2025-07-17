'use client'

import { useEffect, useState, useRef } from 'react'
import { v4 as uuidv4 } from 'uuid'

/** 
 * Base URL for the backend API, injected from environment variable at build time.
 * Must be prefixed with NEXT_PUBLIC_ to be accessible in the browser.
 * Allows switching between environments (e.g., local, Docker, production) without code changes.
 */
const apiBaseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// Derive WebSocket URL from the public API base URL (must be ws:// or wss://).
const wsBaseUrl = (process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000')
  .replace(/^http/, 'ws')

/**
 * Type for valid Black-Scholes input fields.
 * Includes:
 *  - S: Current stock price
 *  - K: Strike price
 *  - r: Risk-free interest rate
 *  - T: Time to maturity (in years)
 *  - sigma: Volatility
 */
type InputKey = 'S' | 'K' | 'r' | 'T' | 'sigma'

/**
 * Home Component
 * ---------------
 * Renders a form for inputting Black-Scholes model parameters and submitting them
 * to a FastAPI backend via HTTP POST. A WebSocket is used to asynchronously receive
 * the result (call and put option prices) once computed.
 */
export default function Home() {
  // Form state for the Black-Scholes input parameters
  const [inputs, setInputs] = useState<Record<InputKey, string>>({
    S: '',
    K: '',
    r: '',
    T: '',
    sigma: '',
  })

  // Stores the result from the server (call and put prices)
  const [result, setResult] = useState<{ call: number; put: number } | null>(null)

  // Generate a unique client ID for identifying this session on the backend (persists for session)
  const [clientId] = useState(uuidv4()) // unique ID per session

  // Reference to WebSocket instance
  const socketRef = useRef<WebSocket | null>(null)

  /**
   * Establishes WebSocket connection on mount.
   * Receives results pushed from backend and updates `result` state.
   * Closes WebSocket on component unmount.
   */
  useEffect(() => {
    const socket = new WebSocket(`${wsBaseUrl}/ws/${clientId}`)

    socket.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        // Expecting data with `call` and `put` values
        if (data.call !== undefined && data.put !== undefined) {
          setResult({ call: data.call, put: data.put })
        }
      } catch (e) {
        console.warn("⚠️ Non-JSON WebSocket message:", event.data, e)
      }
    }

    socketRef.current = socket

    // Clean up the socket when component unmounts
    return () => {
      socket.close()
    }
  }, [clientId])

  /**
   * Updates form input state as user types.
   * Ensures proper mapping of field names to input values.
   */
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setInputs((prev) => ({ ...prev, [name as InputKey]: value }))
  }

  /**
   * Handle form submission:
   * - Sends a POST request with the input data to the FastAPI backend.
   * - Clears the previous result until the WebSocket response arrives.
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setResult(null) // Clear previous result

    const response = await fetch(`${apiBaseUrl}/blackscholes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        S: parseFloat(inputs.S),
        K: parseFloat(inputs.K),
        r: parseFloat(inputs.r),
        T: parseFloat(inputs.T),
        sigma: parseFloat(inputs.sigma),
        client_id: clientId,
      }),
    })

    const data = await response.json()
    console.log('Task queued:', data)
  }

  /**
   * JSX (JavaScript XML) returned by the component:
   * - Form to input parameters
   * - Button to trigger calculation
   * - Result display once data is received
   */
  return (
    <div className="max-w-md mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Black-Scholes Calculator</h1>
      
      {/* Input form */}
      <form onSubmit={handleSubmit} className="space-y-1">
        {(['S', 'K', 'r', 'T', 'sigma'] as InputKey[]).map((key) => (
          <div key={key}>
            <label className="block mb-1">{key}</label>
            <input
              type="number"
              step="any"
              name={key}
              value={inputs[key]}
              onChange={handleChange}
              className="w-full border p-2 rounded"
              required
              placeholder="e.g., 1.0"
            />
          </div>
        ))}

        <button type="submit" className="bg-blue-600 text-white px-4 py-2 rounded">
          Calculate
        </button>
      </form>

      {/* Display the computed result if available */}
      {result && (
        <div className="mt-6">
          <h2 className="text-xl font-semibold">Results</h2>
          <p>Call Price = {result.call.toFixed(4)}</p>
          <p>Put Price  = {result.put.toFixed(4)}</p>
        </div>
      )}
    </div>
  )
}
