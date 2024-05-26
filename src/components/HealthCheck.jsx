// src/components/HealthCheck.jsx
export default function HealthCheck() {
  const currentTime = new Date().toISOString();

  return (
    <div>
      <h1>Health Check</h1>
      <p>Status: OK</p>  
      <p>Timestamp: {currentTime}</p>
    </div>
  );
}