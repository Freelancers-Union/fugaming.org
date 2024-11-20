async function getOnlineMembers() {
  const url =
    "https://census.daybreakgames.com/s:fuofficers/get/ps2:v2/outfit?outfit_id=37509488620602936&c:resolve=member_character&c:join=characters_online_status%5Eon:members.character_id%5Eto:character_id%5Einject_at:character_online_status";

  try {
    const response = await fetch(url, { timeout: 5000 });
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const outfitMembers = await response.json();

    const members = outfitMembers.outfit_list[0].members;
    const onlineMembers = members.filter(
      (member) => member.character_online_status.online_status === "10"
    );
    return onlineMembers.length;
  } catch (error) {
    console.error(`Error fetching online members: ${error}`);
    return 0;
  }
}
