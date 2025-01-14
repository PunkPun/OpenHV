Wave = 1
Breaches = 10

Machine = { "scout1", "scout1", "scout1" }
Rocket = { "scout2", "scout2" }
Tank = { "tank3" }

Waves =
{
	{ delay = 500, units = { Machine, Machine, Machine, Machine } },
	{ delay = 500, units = { Rocket, Rocket, Rocket, Machine, Machine, Machine, Machine, Machine } },
	{ delay = 550, units = { Rocket, Rocket, Rocket, Rocket, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine } },
	{ delay = 600, units = { Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine } },
	{ delay = 650, units = { Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Machine, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine , Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket,Rocket,Rocket,Rocket, Rocket, Rocket, Rocket } },
	{ delay = 650, units = { Tank, Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Machine, Machine, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Machine,Machine,Tank, Machine,Machine, Machine, Machine, Machine , Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket,Rocket,Rocket,Rocket, Rocket, Rocket, Rocket, Tank } },
	{ delay = 700, units = { Tank, Tank, Tank, Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Machine, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine , Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket,Rocket,Rocket,Rocket, Rocket, Rocket, Rocket } },
	{ delay = 800, units = { Tank, Tank, Tank, Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Machine, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine , Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket,Rocket,Rocket,Rocket, Rocket, Rocket, Rocket , Tank, Tank, Tank, Tank, Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Machine, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine , Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket,Rocket,Rocket,Rocket, Rocket, Rocket, Rocket } },
	{ delay = 800, units = { Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank } },
	{ delay = 800, units = { Tank, Tank, Tank, Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Machine, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine , Rocket, Rocket, Tank, Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket,Rocket,Tank, Tank, Rocket,Rocket, Rocket, Tank, Tank,Rocket, Rocket , Tank, Tank, Tank, Tank, Tank, Rocket, Rocket, Rocket, Rocket, Rocket, Machine, Tank, Tank,Machine, Machine, Machine,Machine,Machine,Machine, Machine, Machine, Machine , Tank, Tank,Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket, Rocket,Rocket,Rocket,Tank, Tank,Rocket, Rocket, Rocket, Rocket, Tank, Tank, Tank, Tank } },
	{ delay = 800, units = { Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank , Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank , Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank , Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank, Tank } },
}

LastWave = false

ExitTriggerArea = { ExitWaypoint1.Location, ExitWaypoint2.Location }

function CenterCamera()
	Camera.Position = WPos.New(Map.BottomRight.X / 2, Map.BottomRight.Y / 2, 0)
end

WorldLoaded = function()
	CenterCamera()

	HumanPlayer = Player.GetPlayer("Multi0")
	EnemyPlayer = Player.GetPlayer("Creeps")

	TowerDefenseObjective = AddPrimaryObjective(HumanPlayer, "not-too-many-enemies-through-trench")
	UpdateGameStateText()

	Trigger.OnEnteredFootprint(ExitTriggerArea, function(actor)
		actor.Destroy()
		Breaches = Breaches - 1
		if Breaches < 1 then
			HumanPlayer.MarkFailedObjective(TowerDefenseObjective)
		end
		UpdateGameStateText()
	end)

	SendNextWave()
end

CachedWaves = -1
CachedBreaches = -1
function UpdateGameStateText()
	if CachedWaves == Waves then
		return
	end
	CachedWaves = Waves

	if CachedBreaches == Breaches then
		return
	end
	CachedBreaches = Breaches

	local currentWave = UserInterface.Translate("current-wave", { ["wave"] = Wave, ["waves"] = #Waves })
	local tolerableBreaches = UserInterface.Translate("tolerable-breaches", { [ "breaches"] = Breaches })
	UserInterface.SetMissionText("\n\n\n" .. currentWave .. "\n\n" .. tolerableBreaches)
end


SendNextWave = function()
	local wave = Waves[Wave]
	Trigger.AfterDelay(wave.delay, function()
		Utils.Do(wave.units, function(units)
			Attackers = Reinforcements.Reinforce(EnemyPlayer, units, { EntryWaypoint1.Location, ExitWaypoint1.Location })
		end)
		UpdateGameStateText()
		if Wave < #Waves then
			Wave = Wave + 1
			SendNextWave()
		else
			LastWave = true
		end
	end)
end

Won = false
Tick = function()
	if LastWave and not HumanPlayer.IsObjectiveCompleted(TowerDefenseObjective) then
		Trigger.AfterDelay(200, function()
			if not Won and #EnemyPlayer.GetGroundAttackers() == 0 then
				Media.DisplayMessage(UserInterface.Translate("no-more-enemies"))
				HumanPlayer.MarkCompletedObjective(TowerDefenseObjective)
				Won = true
			end
		end)
	end
end
