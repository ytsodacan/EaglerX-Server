g_PluginInfo =
{
	Name = "MCArena",
	Date = "2015-03-14",
	Description = "Provides kit PvP functionality to MCServer",

	AdditionalInformation = 
	{
		{
			Title = "Creating your first arena",
			Comments = [[Step 1: You must be an admin.  Give yourself a golden pickaxe.

				Step 2: While holding the golden pickaxe, left click one corner of the cuboid that you would
				like to define and right click the opposite corner.  Shift and click with either button to select the
				spectator teleport position for that arena.

				Step 3: Use the following command to create your arena:  /mca create [Arena Name Here]
				This will add your arena to "arenas.cfg" and you're done.

				Step 4: Testing.  Use /mca list to list all avaliable arenas.  When you would like to join it, 
				use /mca join default.  Keep in mind that "default" is the name of the kit.  You will be placed in
				a random arena if multiple ones exist.  This is due to the player queue used to match up players.

				Step 5: Enjoy!  The arena that was just created should be self-managing and contains any players that
				are fighting within it.]],
		},

		{
			Title = "Joining an arena",
			Comments = [[Use "/mca listkits" to list all of the avaliable kits on the kits.ini file.
				Then, choose a kit and use /mca join {Kit Name Here}.

				This will put you in a queue line
				with other players.  Once enough players have joined, all the players will be placed into a single arena 
				where everyone fights to the death.  Upon death or victory, you will be restored to your previous player
				state.  (Position, Inventory, Health, etc...)]],
		},

		{

			Title = "Creating kits",
			Comments = [[Whenever one joins an arena, they are required to select a kit.  A kit is created upon plugin
				installation called "default".  This most likely isn't sufficient though as its only made up of a 
				single diamond sword.  To edit kits, you must edit the Plugins/MCArena/kits.ini file.  To create a new kit, 
				do the following:
				
				1.  Create a new key name.  It's typically a single word surrounded by a pair of square brackets.

				[default]
				item1=276
				amount1=1

				-> [archer]

				2.  Add your items.  All items must be added by numeric ID.  for each item, use a value before it called
				"item" followed by the 'n'th item of that kit.

				[default]
				item1=276
				amount1=1

				[archer]
				item1=261	(This is a bow)
				item2=262	(arrows)

				3.  This is good and all, but how do you give someone for instance, a stack of arrows?  I don't wanna put in
				64 item tags for arrows.  :(

				Fortunately for you, I've simplified that.  :)

				What you do is you add an amount tag to that item number like so:

				[default]
				item1=276
				amount1=1

				[archer]
				item1=261	("amount1" is not needed for single items)
				item2=262	(arrows)
				-> amount2=64	(This represents the amount of item2.  See the pattern?)

				Once you have inserted all of your items into the kit, you're done.  :D
				Also, armor auto-equips itself.  Any second pieces of armor of the same type will overwrite the first.
				Save, close and reload the server.  Remember, choosing a kit is CaSe-SeNsItIvE by default.]]
		}
	},

	Commands = 
	{
		["/mca"] = 
		{
			HelpString = "The main MCArena command",
			Permissions = "mcarena.use",
			Handler = CommandManager,
			ParameterCombinations =
			{
				{
					Params = "join [kit]",
					Help = "Join the queue with the specified kit",
				},
				{
					Params = "spec [arenaname]",
					Help = "Spectate the specified arena",
				},
				{
					Params = "list",
					Help = "Lists the names of existing arenas",
				},
				{
					Params = "listkits",
					Help = "Lists the names of existing kits",
				},
				{
					Params = "create [newname]",
					Help = "Creates a new arena with the specified name if provided with selected coords.",
				},
				{
					Params = "wand",
					Help = "Gives those with permission a selection tool.",
				},
				{
					Params = "qleave",
					Help = "Exits queue.",
				},
				{
					Params = "sleave",
					Help = "Exits spectator mode.",
				},
			}
		}
	},

	ConsoleCommands = 
	{
	},

	Permissions =
	{
		["mcarena.use"] =
		{
			Description = "Allows the to participate in MCArena.",
			RecommendedGroups = "Default",
		},
		["mcarena.edit"] =
		{
			Description = "Allows admins to create/edit arenas.",
			RecommendedGroups = "Admin",
		},
	},
}
