({
	getLeadSelected: function (component, event, helper) {
		var action = component.get('c.getLeadListSelected');

		var fromVF = component.get("v.recordList");
		console.log('fromVF ' + fromVF);
		component.set("v.jsonRecordList", JSON.parse(fromVF));

		/*console.log('Case1' + recordIdsList[0]);
		console.log('Case1' + recordIdsList[1]);*/

		action.setParams({
			/*'casesIdSelected': recordIdsList,*/
			'leadsId': JSON.parse(fromVF),
			'myJsonString': fromVF
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			console.log('apex' + state);
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				console.log('result ---->' + JSON.stringify(result));
				component.set('v.leadSelectedList', result['leadList']);
				component.set('v.data', result['leadList']);
				component.set('v.leadsListIds', result['leadListIds']);
			} else if (state === 'INCOMPLETE') {
                component.set('v.errorMsg', response.getError());
				console.log('Incompleted request' + response.getError());

			} else if (state === 'ERROR') {
				console.log('apex error' + response.getError());
			}

		});

		$A.enqueueAction(action);
	},

	sendLeadListToClose: function (component, event, helper) {
		component.set('v.loaded', !component.get('v.loaded'));
		var leadSelectedList = component.get('v.leadSelectedList');
		var leadClosed = component.get("v.leadClosed");
		var leadSelectedIds = component.get('v.leadsListIds');
		var action = component.get("c.closeSaveLeads");

		action.setParams({
			leadResult: leadClosed,
			leadSelectedList: leadSelectedList,
			leadSelectedIds: leadSelectedIds
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                var result = response.getReturnValue();
				component.set("v.warningMsg", result['message']);
			} else if (state === 'INCOMPLETE') {
				component.set("v.errorMsg", 'Incomplete_Request');

			} else if (state === 'ERROR') {
				// Javascript error
				var error = response.getError();
				console.info('Developer error: ', error);
				component.set('v.errorMsg', 'Ups! Something has gone wrong.');
			}
			component.set('v.loaded', !component.get('v.loaded'));
		});

		$A.enqueueAction(action);
	}

})