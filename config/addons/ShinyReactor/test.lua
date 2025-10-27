c = require('colors')
return {
    {
        Abilities = { 'Claw Cyclone', 'Razor Fang' },
        Users = '*',
        Reaction = '/ja "Violent Flourish" $user',
		Color = nil,	--No color applied
        MustTargetSelf = false,
    },
    {
        Abilities = { },
        Spells = { 'Stoneskin' },
        Users = '*',
        Reaction = '/echo Stoneskin = Purple',
		Color = c.purple,
        MustTargetSelf = true,
    },
	{
        Abilities = { },
        Spells = { 'Blink' },
        Users = '*',
        Reaction = '/echo Blink = Dark Yellow',
		Color = c.yellow,
        MustTargetSelf = true,
    },
	{
        Abilities = { },
        Spells = { 'Cure' },
        Users = '*',
        Reaction = '/echo Cure 1 = Red',
		Color = c.ice_blue,
        MustTargetSelf = true,
    },
    {
        Abilities = { },
        Spells = { 'Cure II' },
        Users = '*',
        Reaction = '/echo Cure 2 = Blue',
		Color = c.blue,
        MustTargetSelf = true,
    },
    {
        Abilities = { },
        Spells = { 'Cure III' },
        Users = '*',
        Reaction = '/echo Cure 3 = Green',
		Color = nil,	--No color applied
        MustTargetSelf = true,
    },
};