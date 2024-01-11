//Enemy Data
global.entities =
{
	lulu: {
		name: "Lulu",
		hp: 89,
		hpMax: 89,
		mp: 15,
		mpMax: 15,
		strength: 6,
		haste: 9,
		sprites : { idle: sLuluIdle, attack: sLuluAttack, defend: sLuluDefend, down: sLuluDown},
		actions : [global.actionLibrary.attack, global.actionLibrary.hastega, global.actionLibrary.cure, global.actionLibrary.defend],
		statuses: {
			defenseMult: 1,
			hasteMult: 1,
		},
	},
	questy: {
		name: "Questy",
		hp: 44,
		hpMax: 44,
		mp: 30,
		mpMax: 30,
		strength: 4,
		haste: 2,
		sprites : { idle: sQuestyIdle, attack: sQuestyCast, cast: sQuestyCast, down: sQuestyDown},
		actions : [global.actionLibrary.attack, global.actionLibrary.ice, global.actionLibrary.restore, global.actionLibrary.defend],
		statuses: {
			defenseMult: 1,
			hasteMult: 1,
		},
	},
	slimeG: {
		name: "Slime",
		hp: 30,
		hpMax: 30,
		mp: 0,
		mpMax: 0,
		strength: 5,
		haste: 5,
		sprites: { idle: sSlime, attack: sSlimeAttack},
		actions: [global.actionLibrary.attack],
		xpValue : 15,
		statuses: global.statuses,
		AIscript : function()
		{
			// Pick first action
			var _action = actions[0];
			
			// Pick from alive targets in the party
			var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index) {
				return (_unit.hp > 0);
			});	
			// Pick random target
			var _target = _possibleTargets[irandom(array_length(_possibleTargets) - 1)];
		
			return [_action, _target];
		}
	},
	bat: {
		name: "Bat",
		hp: 15,
		hpMax: 15,
		mp: 20,
		mpMax: 20,
		strength: 4,
		haste: 8,
		sprites: { idle: sBat, attack: sBatAttack},
		actions: [global.actionLibrary.ice],
		xpValue : 18,
		statuses: global.statuses,
		AIscript : function() {
			// Pick first action
			var _action = actions[0];
			
			// Pick from alive targets in the party
			var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index) {
				return (_unit.hp > 0);
			});	
			// Pick random target
			var _target = _possibleTargets[irandom(array_length(_possibleTargets) - 1)];
		
			return [_action, _target];
		}
	}
}

//Party data
global.party = [global.entities.lulu, global.entities.questy];
for(var i = 0; i < array_length(global.party); i++) {
	global.party[i].statuses.statusIndex = 0;	
}