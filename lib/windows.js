/* eslint-disable new-cap */
'use strict';
const activeWin = require('active-win')
async function windows() {
	const activeWindow = await activeWin()

	return activeWindow;
	/* eslint-enable new-cap */
}

module.exports = () => Promise.resolve(windows());
module.exports.sync = windows;
