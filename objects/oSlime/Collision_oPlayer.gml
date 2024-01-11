// When collide with slime, start encounter
var _numEnemies = irandom_range(1, 3);
var _enemies = [];
for(var i = 0; i < _numEnemies; i++) {
	var _enemyToPick = enemies[irandom_range(0, array_length(enemies) - 1)];
	array_push(_enemies, global.entities[$ _enemyToPick]);
}

NewEncounter(_enemies, sBgField);