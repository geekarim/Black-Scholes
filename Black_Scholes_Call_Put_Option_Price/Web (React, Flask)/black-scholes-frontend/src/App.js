import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [formData, setFormData] = useState({
    S: '',
    K: '',
    T: '',
    r: '',
    sigma: ''
  });

  const [callOptionPrice, setCallOptionPrice] = useState(null);
  const [putOptionPrice, setPutOptionPrice] = useState(null);

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

    const response = await fetch('http://127.0.0.1:5000/api/calculate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(formData)
    });

    const data = await response.json();
    setCallOptionPrice(data.call_price);
    setPutOptionPrice(data.put_price);
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
            name="S"
            value={formData.S}
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
            name="K"
            value={formData.K}
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
            name="T"
            step="0.01"
            value={formData.T}
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
            name="r"
            step="0.01"
            value={formData.r}
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
            name="sigma"
            step="0.01"
            value={formData.sigma}
            onChange={handleChange}
            required
            placeholder="e.g., 0.2"
          />
        </div>

        <button type="submit">Calculate</button>
      </form>


      {callOptionPrice !== null && putOptionPrice !== null && (
        <div className="result">
          <h2>Call Option Price: {callOptionPrice}</h2>
          <h2>Put Option Price: {putOptionPrice}</h2>
        </div>
      )}
    </div>
  );
}

export default App;
