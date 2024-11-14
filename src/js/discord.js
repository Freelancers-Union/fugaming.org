document.addEventListener("DOMContentLoaded", function () {
  fetch("https://discord.com/api/v9/invites/axzCaZq?with_counts=true")
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok " + response.statusText);
      }
      return response.json();
    })
    .then((data) => {
      console.log("API response:", data); // Log the API response
      const memberCount = data.approximate_member_count;

      document.getElementById(
        "member-count"
      ).textContent = `${memberCount} members`;
    })
    .catch((error) => console.error("Error fetching member count:", error));
});
