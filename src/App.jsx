// src/App.jsx
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Welcome from './components/Welcome';
import HealthCheck from './components/HealthCheck';
import CurrentWeather from './components/CurrentWeather';

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Welcome />} />
        <Route path="/health" element={<HealthCheck />} />
        <Route path="/weather" element={<CurrentWeather />} />
      </Routes>
    </Router>
  );
}