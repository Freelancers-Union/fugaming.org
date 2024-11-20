function updateLocalTime(elementId, time) {
  const [hours, minutes] = time.split(":").map(Number);
  const now = new Date();
  now.setHours(hours, minutes, 0, 0); // Set the given time

  const options = { hour: "2-digit", minute: "2-digit", timeZoneName: "short" };
  const localTime = now.toLocaleTimeString([], options);
  document.getElementById(elementId).textContent = localTime;
}
