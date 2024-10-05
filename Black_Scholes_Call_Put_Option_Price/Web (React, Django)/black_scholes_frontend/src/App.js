import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [formData, setFormData] = useState({
    underlying_price: '',
    strike_price: '',
    time_to_expiry: '',
    volatility: '',
    risk_free_rate: ''
  });
  const [result, setResult] = useState(null);

  // New state for dark mode
  const [isDarkMode, setIsDarkMode] = useState(false);
  useEffect(() => {
    // Toggle dark mode on the body element
    if (isDarkMode) {
      document.body.classList.add('dark');
    } else {
      document.body.classList.remove('dark');
    }
  }, [isDarkMode]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch('http://127.0.0.1:8000/api/black-scholes/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      });
      const data = await response.json();
      setResult(data);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  // Toggle dark mode
  const toggleDarkMode = () => {
    setIsDarkMode(!isDarkMode);
  };

  return (
    <div className="container">
      <h1>Black-Scholes Option Calculator</h1>

      <div className="form-group">
        {/* Button to toggle dark mode */}
        <button onClick={toggleDarkMode}>
          {isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
        </button>
      </div>

      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>
            Stock Price (S):
          </label>
          <input
            type="number"
            name="underlying_price"
            value={formData.underlying_price}
            onChange={handleChange}
            required
            placeholder="e.g., 100"
          />
        </div>

        <div className="form-group">
          <label>
            Strike Price (K):
          </label>
          <input
            type="number"
            name="strike_price"
            value={formData.strike_price}
            onChange={handleChange}
            required
            placeholder="e.g., 100"
          />
        </div>

        <div className="form-group">
          <label>
            Time to Maturity (T in years):
          </label>
          <input
            type="number"
            name="time_to_expiry"
            step="0.01"
            value={formData.time_to_expiry}
            onChange={handleChange}
            required
            placeholder="e.g., 3"
          />
        </div>

        <div className="form-group">
          <label>
            Risk-free Rate (r):
          </label>
          <input
            type="number"
            name="risk_free_rate"
            step="0.01"
            value={formData.risk_free_rate}
            onChange={handleChange}
            required
            placeholder="e.g., 0.02"
          />
        </div>

        <div className="form-group">
          <label>
            Volatility (σ):
          </label>
          <input
            type="number"
            name="volatility"
            step="0.01"
            value={formData.volatility}
            onChange={handleChange}
            required
            placeholder="e.g., 0.2"
          />
        </div>
        <button type="submit">Calculate</button>
      </form>

      {result && (
        <div className="result">
          <h2>Call Option Price: {result.call_option_price}</h2>
          <h2>Put Option Price: {result.put_option_price}</h2>
        </div>
      )}
    </div>
  );
}



export default App;
