// src/components/CurrentWeather.jsx
import { useState, useEffect } from 'react';

export default function CurrentWeather() {
  const [weatherData, setWeatherData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchWeatherData = async () => {
      try {
        const response = await fetch(
          'https://api.open-meteo.com/v1/forecast?latitude=40.769883744600065&longitude=-73.98379341590314&current_weather=true&temperature_unit=fahrenheit&wind_speed_unit=mph'
        );
        const data = await response.json();
        setWeatherData(data);
        setLoading(false);
      } catch (error) {
        setError('Failed to fetch weather data');
        setLoading(false);
      }
    };

    fetchWeatherData();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div>
      <h1>Current Weather</h1>
      <p>Temperature: {weatherData.current_weather.temperature}°F</p>
      <p>Wind Speed: {weatherData.current_weather.windspeed} mph</p>
    </div>
  );
}