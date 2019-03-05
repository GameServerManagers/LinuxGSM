#!/bin/bash
# LinuxGSM fix_cfwf.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Citadel: Forged With Fire.

engine_ini_config="[url]\nPort=7777"
game_ini_config="[UWorks]\nConnectionPort=7777\nQueryPort=27015\n\n[/script/citadel.socialmanager]\nPassword=CHANGEME\n\n[/Game/UI/QualityMenu/Blueprints/BP_GameInstanceWithSettings.BP_GameInstanceWithSettings_C]\nWorldCreationSettings=(ServerName=\"LinuxGSM\",ServerType=PVP,PlayerLimit=40,bPrivate=False,Password=\"\",UniqueOfficialServerKey=\"\",ExperienceMultiplier=1.000000,KnowledgePointEarnedMultiplier=1.000000,CharacterPointEarnedMultiplier=1.000000,bUnlimitedResources=False,PlayerDamageMultiplier=1.000000,ArmorMultipler=1.000000,BaseManaRegen=1.000000,InventoryCapacityMultipler=1.000000,bInventoryWeightRestrictions=True,MagicFindMultiplier=1.000000,FlyingCostMultiplier=1.000000,FlyingSpeedMultiplier=1.000000,bFlyingIsFree=False,StructureDecayMultiplier=1.000000,bThronesDecay=True,ResourceCollectionMultiplier=1.000000,StructureDamageMultiplier=1.000000,bRespectNoBuildZones=True,MagicStructureManaRegenerationMultiplier=1.000000,MagicStructureManaConsumptionMultiplier=1.000000,TimeOfDayLock=Auto,NPCPopulationMultiplier=1.000000)"

configure_engine_ini ()  {
	echo "${engine_ini_config}" >> ${serverfiles}/Citadel/Saved/Config/LinuxServer/Engine.ini  &>/dev/null
}

configure_game_ini () {
	echo "${game_ini_config}" >> ${serverfiles}/Citadel/Saved/Config/LinuxServer/Game.ini  &>/dev/null
}

# Check if steamclient.so is available in correct Plugins folder and copy if necessary.
if [ ! -f "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so" ]; then
        cp -f "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so"  &>/dev/null

# Verify version of steamclient and copy to Plugins folder if version mismatch.
elif [ "$(diff "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so" >/dev/null)" ]; then
        cp -f "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so"  &>/dev/null
fi

# Check if config directory is available, if not create directory
if [ ! -d ${serverfiles}/Citadel/Saved/Config/LinuxServer/ ]; then
	mkdir -p ${serverfiles}/Citadel/Saved/Config/LinuxServer/  &>/dev/null
fi

# Ensures engine.ini exists and contains data
if [ ! -f ${serverfiles}/Citadel/Saved/Config/LinuxServer/Engine.ini ]; then
	touch ${serverfiles}/Citadel/Saved/Config/LinuxServer/Engine.ini  &>/dev/null
	configure_engine_ini

elif [ ! -s ${serverfiles}/Citadel/Saved/Config/LinuxServer/Engine.ini ]; then
	configure_engine_ini  &>/dev/null
fi

# Ensures game.ini exists and contains data
if [ ! -f ${serverfiles}/Citadel/Saved/Config/LinuxServer/Game.ini ]; then
        touch /home/cfwfserver/serverfiles/Citadel/Saved/Config/LinuxServer/Game.ini  &>/dev/null
	configure_game_ini

elif [ ! -s /home/cfwfserver/serverfiles/Citadel/Saved/Config/LinuxServer/Game.ini ]; then
        configure_game_ini
fi