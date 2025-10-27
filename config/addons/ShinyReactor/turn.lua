return {
	--Turn Away
    {
        Abilities = { 'Afflicting Gaze', 'Apocalyptic Ray', 'Awful Eye', 'Baleful Gaze', 'Beguiling Gaze', 'Belly Dance', 'Bill Toss', 'Blank Gaze', 'Blight Dance', 'Blink of Peril', 'Calcifying Deluge', 'Chaotic Eye', 'Chthonian Ray', 'Cold Stare', 'Crush Gaze', 'Dark Thorn', 'Deathly Glare', 'Eternal Damnation', 'Fatal Allure', 'Frigid Shuffle', 'Gerjis\' Grip', 'Hex Eye', 'Hypnic Lamp', 'Hypnosis', 'Hypnotic Sway', 'Jettatura', 'Light of Penance', 'Luxurious Dance', 'Minax Glare', 'Mind Break', 'Mortal Blast', 'Mortal Ray', 'Numbing Glare', 'Petro Eyes', 'Pain Sync', 'Petrifying Dance', 'Petro Gaze', 'Poisonous Dance', 'Predatory Glare', 'Primordial Surge', 'Raqs Baladi Dance', 'Sand Trap', 'Slyvan Slumber', 'Tormentful Glare', 'Torpefying Charge', 'Torpid Glare', 'Vacant Gaze', 'Vile Belch', 'Washtub', 'Yawn', },
        Spells = { 'Dread Spikes', },
        Users = {'*'},
        Reaction = '/turn awayfrom $userindex',
        MustTargetSelf = false,
    },

	--Turn Towards
    {
        Abilities = { 'Chastening Disregard', 'Expunge', 'Impaling Disregard', 'Impale', 'Waning Vigor' },
        Users = {'*'},
        Reaction = '/turn toward $userindex',
        MustTargetSelf = false,
    },
};
