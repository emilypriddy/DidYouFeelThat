require('cloud/app.js');
var _ = require('underscore');
var moment = require('cloud/moment.js');
var USGSQuakes = Parse.Object.extend("USGSQuakes");
var PubNub = require('cloud/pubnub.js');
var pubnub = {
  'publish_key' : 'pub-c-4fd8c17f-482b-4a3f-bd5d-1f326d809f0a',
  'subscribe_key' : 'sub-c-3f98a0c2-e6e3-11e4-a30c-0619f8945a4f'
};

// Parse.Cloud.job('eventsCreated', function)

Parse.Cloud.job('usgsJob', function(request, response) {
  return Parse.Cloud.httpRequest({
    url: 'http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson'
  }).then(function(httpResponse) {
    var jsonResponse = httpResponse.text;
    var someJSON = JSON.parse(httpResponse.text);
    
    var listArray = [];

    for (var i = 0; i < someJSON.features.length; i++) {
      var usgsQuakes = new USGSQuakes();
      var item = someJSON.features[i];
      var point = new Parse.GeoPoint({latitude: item.geometry.coordinates[1], longitude: item.geometry.coordinates[0]});
      var detailURL = item.properties.detail;
      var itemCountry, itemState;
      // var itemCountry = item.properties.products.geoserve.properties.country;
      // var itemState = item.properties.products.geoserve.properties.state;
      
      usgsQuakes.set("cdi", item.properties.cdi);
      usgsQuakes.set("country", itemCountry);
      usgsQuakes.set("depth", item.geometry.coordinates[2]);
      usgsQuakes.set("detailURL", item.properties.detail);
      usgsQuakes.set("eventType", item.properties.type);
      usgsQuakes.set("felt", item.properties.felt);
      usgsQuakes.set("latitude", item.geometry.coordinates[1]);
      usgsQuakes.set("location", point);
      usgsQuakes.set("longitude", item.geometry.coordinates[0]);
      usgsQuakes.set("mag", item.properties.mag);
      usgsQuakes.set("place", item.properties.place);
      usgsQuakes.set("state", itemState);
      usgsQuakes.set("time", item.properties.time);
      usgsQuakes.set("timestamp", new Date());
      usgsQuakes.set("title", item.properties.title);
      usgsQuakes.set("tz", item.properties.tz);
      usgsQuakes.set("updated", item.properties.updated);
      usgsQuakes.set("usgsCode", item.properties.code);
      usgsQuakes.set("usgsId", item.id);

      listArray.push(usgsQuakes);
    }

    var promises = [];
    Parse.Object.saveAll(listArray, {
      success: function(objs) {
        promises.push(objs);
        Parse.Cloud.run("fetchQuakeDetails", objs);
        response.success("SAVED ALL!");
      },
      error: function(error){
        response.error("ERROR WHILE SAVING - "+error);
      }
    });
  return Parse.Promise.when(promises);
  
  }).then(function() {
    response.success("Saving completed successfully."); 
  }, function(error) {
    response.error("Uh oh, something went wrong");
  });
});

Parse.Cloud.define("fetchQuakeDetails", function(request, response){
	console.log("Inside fetchQuakeDetails " + request.params.objs);
	// return Parse.Cloud.httpRequest({
	// 	url:
	// })
});

Parse.Cloud.beforeSave("USGSQuakes", function(request, response) {
  if(!request.object.isNew()){
    // Let existing object updates go through
    console.log("!request.object.isNew(). Let existing object updates go through.");
    response.success();
  }
  var query = new Parse.Query(USGSQuakes);
  // Add query filters to check for uniqueness
  query.equalTo("usgsId", request.object.get("usgsId"));
  query.first().then(function(existingObject){
    if(existingObject){
      // Update existing object
      console.log("if(existingObject) - Update existing object.");

      existingObject.increment("timesUpdated");
      existingObject.set("felt", request.object.get("felt"));
      existingObject.set("cdi", request.object.get("cdi"));
      existingObject.set("mag", request.object.get("mag"));
      existingObject.set("title", request.object.get("title"));
      existingObject.set("updated", request.object.get("updated"));
      existingObject.set("depth", request.object.get("d"));
      existingObject.set("latitude", request.object.get("latitude"));
      existingObject.set("longitude", request.object.get("longitude"));
      existingObject.set("eventType", request.object.get("eventType"));

      return existingObject.save();
    } else {
      console.log("else(!existingObject) - Parse.Promise.as(false)");
      // Pass a flag that this is not an existing object
      return Parse.Promise.as(false);
    }
  }).then(function(existingObject){
    if(existingObject){
      // Existing object, stop initial save
      console.log("Existing object. Stopping initial save.");
      response.error("Existing object. Stopping initial save.");
    } else {
      // New object, let the save go through
      console.log("New object, let the save go through.");
      response.success();
    }
  }, function(error){
  	console.log("Error performing checks or saves. - console.log");
    response.error("Error performing checks or saves.");
  });
});

Parse.Cloud.afterSave("USGSQuakes", function(request) {
	Parse.Cloud.useMasterKey();

	var quake = request.object;
  var quakeTitle = quake.get('title');
  var quakeUsgsId = quake.get('usgsId');
  // var quakeCountry = quake.get('country');
  // var quakeState = quake.get('state');
  var pushStatus = quake.get('pushSent');
  var pubnubChannel = quakeUsgsId;

  // Temporarily setting the quakeState and quakeCountry vars to "OK" to test other parts of this code.

  var quakeCountry = "United States";
  var quakeState = "Oklahoma";
  var quakeChannel = 'Oklahoma';

  if (!pushStatus || pushStatus === undefined) {
  	quake.save({
      pushSent: true
    }, {
    	success: function(quake) {
		  	var pushQuery = new Parse.Query(Parse.Installation);
		  	pushQuery.equalTo('channels', quakeChannel);
		  	
		  	var installations = [];
		  	pushQuery.find().then(function(objects) {
		  		for (var i = 0; i < objects.length; i++) {
		  			var install = objects[i];
		  			installations.push(install);
		  		};
		  		installations.push(Parse.Push.send({
						where: pushQuery,
						data: {
							alert: quakeTitle + " " + install.id,
		          badge: "Increment",
		          category: "DidYouFeelItEventCategory",
		          qid: quakeUsgsId
						}
					}).then(function(){
						console.log("Inside push to " + install.id + " - success!");
						// subscribeUsersToChannel(install, quakeChannel, pubnubChannel, {
						Parse.Cloud.run("subscribeUsersToChannel", { deviceToken: install.get('deviceToken'), quakeChannel: quakeChannel, pubnubChannel: pubnubChannel }, {
				  		success: function(result) {
				  			console.log("Inside afterSave's subscribeUsersToChannel - success! " + result);
				  		}, error: function(error) {
				  			console.log("Inside afterSave's subscribeUsersToChannel - error: " + error.message);
				  		}
				  	});
					}, function(error) {
						console.log("Inside push to " + install.id + " - error: " + error.message);
					})); // end installations.push
		  	}); // end pushQuery.find()
		  }, // end success: function(quake)
		  error: function(quake, error){
		  	// The save failed
		  	console.log("The save inside afterSave failed. " + error.message);
		  }
		});
	}
});

Parse.Cloud.define("subscribeUsersToChannel", function(request, response) {
	Parse.Cloud.useMasterKey();

	var deviceToken = request.params.deviceToken;
	var pubnubChannel = request.params.pubnubChannel;
	var quakeChannel = request.params.quakeChannel;

	var myPushURL = 'http://pubsub.pubnub.com/v1/push/sub-key/' +
    pubnub.subscribe_key + 
    '/devices/' + deviceToken + '?add=' +
    pubnubChannel + '&type=apns';

	var myPublishURL =  'https://pubsub.pubnub.com/publish/' + 
		pubnub.publish_key +  '/' +
		pubnub.subscribe_key + '/0/' + 
		pubnubChannel + '/0/';

	var message = {
    'from' : 'PubNub+Parse',
    'to' : 'installationQuery',
    'message' : 'Hello from quake channel ' + quakeChannel
  }

	console.log("Inside subscribeUsersToChannel - " + deviceToken);

	

	Parse.Cloud.httpRequest({
		url: myPushURL,
	  success: function(httpResponse) {
	    console.log('Subscribed to pubnubChannel' + ' ' + pubnubChannel + ' - '+ httpResponse.text);
	    Parse.Cloud.run("publishFromUserToChannel", { deviceToken: deviceToken, quakeChannel: quakeChannel, pubnubChannel: pubnubChannel }, {
	  		success: function(result) {
	  			console.log("Inside subscribeUsersToChannel's publishFromUserToChannel - success! " + result);
	  		}, error: function(error) {
	  			console.log("Inside subscribeUsersToChannel's publishFromUserToChannel - error: " + error.message);
	  		}
	  	});
	  }, 
	  error: function(httpResponse) {
	    // error
	    console.error('Subscribing to pubnubChannel request failed with response code ' + httpResponse.status);
	  }
	}).then(function() {
		console.log("Success!");
		response.success(true);
	}, function(error) {
		console.log("Error! " + error.message);
	}); // end Parse.Cloud.httpRequest - myPushURL
});

Parse.Cloud.define("publishFromUserToChannel", function(request, response) {
	Parse.Cloud.useMasterKey();

	var deviceToken = request.params.deviceToken;
	var pubnubChannel = request.params.pubnubChannel;
	var quakeChannel = request.params.quakeChannel;

	var myPublishURL =  'https://pubsub.pubnub.com/publish/' + 
		pubnub.publish_key +  '/' +
		pubnub.subscribe_key + '/0/' + 
		pubnubChannel + '/0/';

	var message = {
    'from' : 'deviceToken - ' + deviceToken,
    'to' : 'pubnubChannel - ' + pubnubChannel,
    'message' : 'Hello from quake channel ' + quakeChannel
  }

	console.log("Inside publishFromUserToChannel - " + deviceToken);

	/* Publish String on pubnub channel */

	console.log("myPublishURL = " + myPublishURL);

	Parse.Cloud.httpRequest({
	  url: myPublishURL +
	    encodeURIComponent(JSON.stringify(message)),
	  success: function(httpResponse) {
	    // success
	    console.log('publish from Cloud worked?' + httpResponse.text);
	  }, 
	  error: function(httpResponse) {
	    // error
	    console.error('Request failed with response code ' + httpResponse.status);
	  }
	}).then(function() {
			console.log("Success!");
			response.success(true);
		}, function(error) {
			console.log("Error! " + error.message);
	}); // end Parse.Cloud.httpRequest - myPublishURL
});

Parse.Cloud.beforeSave("UserEvent", function(request, response) {
	var quakeEvent = request.object;

	var MIN_IN_MS = 60 * 1000;
	var HOUR_IN_MS = 60 * MIN_IN_MS;
	var DAY_IN_MS = 24 * HOUR_IN_MS;
	
	var twoMinutes = 2 * MIN_IN_MS;
	var fiveMinutes = 5 * MIN_IN_MS;
	var tenMinutes = 10 * MIN_IN_MS;
	var fifteenMinutes = 15 * MIN_IN_MS;

	var today = new Date();
	var tenMinutesAgo = new Date(today - tenMinutes);
	var twoMinutesAgo = new Date(today - twoMinutes);

	var query = new Parse.Query("UserEvent");

	query.greaterThan("createdAt", twoMinutesAgo);

	query.find({
		success: function(results) {
			if(results.length > 0) {
				var relation = quakeEvent.relation("possibleRelatedEvents");
				for (i = 0; i < results.length; i++) {
					var dataCreated = results[i];
					relation.add(dataCreated);
				}
				// console.log("finalArray = " + finalArray);
				// Parse.Cloud.run("addReverseRelation", { eventsArray: finalArray, relatedEvent: quakeEvent }, {
				// 	success: function(reverseResult) {
				// 		console.log("Inside afterSave's addReverseRelation call - success! - " + reverseResult);
				// 	}, error: function(reverseError) {
				// 		console.log("Inside afterSave's addReverseRelation call - error! - " + reverseError);
				// 	}
				// });
			}
		},
		error: function() {
			console.log("time lookup failed");
		}
	}).then(function(successful){
		response.success();
	}, function(error) {
		response.error("Error saving UserEvent!");
	});
});

Parse.Cloud.afterSave("UserEvent", function(request) {

	// var userEvent = request.object;
	// var relatedEvents = userEvent.relation("possibleRelatedEvents");

	// var query = new Parse.Query("UserEvent");
	// var listArray = [];
	// query.include(relatedEvents).find({
	// 	success: function(list) {
	// 		console.log("Inside query success! - " + list);
	// 		for (i = 0; i < list.length; i++){
	// 			var reverseEvent = list[i];
	// 			console.log("reverseEvent.id = " + reverseEvent.id);
	// 			var reverseRelation = reverseEvent.relation("possibleRelatedEvents");
	// 			reverseRelation.add(userEvent);
	// 			listArray.push(reverseEvent);
	// 		}

	// 	},
	// 	error: function(error) {
	// 		console.log("Inside query error! - " + error);
	// 	}
	// }).then(function() {
	// 	Parse.Object.saveAll(listArray, {
	// 			success: function(objs) {
	// 				console.log("saveAll success! - " + objs);
	// 			},
	// 			error: function(error) {
	// 				console.log("saveAll error! - " + error);
	// 			}
	// 		});
	// 	console.log("End of saveAll Success!!");
	// }, function(error) {
	// 	console.log("End of saveAll Error!! - " + error);
	// });
	
	

	// console.log("relatedEvents.description = " + relatedEvents.description);

	// if (relatedEvents.length > 0) {
	// 	console.log("relatedEvents[0].objectId = " + relatedEvents[0].objectId);
	// 	for (i=0; i < relatedEvents.length; i++) {
	// 		var eventI = relatedEvents[i];
	// 		console.log("eventI.objectId = " + eventI.objectId);
	// 	}
	// 	relatedEvents.query().find({
	// 		success: function(list) {
	// 			console.log("list = " + list);
	// 		},
	// 		error: function(error) {
	// 			console.log("list error = " + error.message + " " + error.code);
	// 		}
	// 	});
	// }


});

// Parse.Cloud.define("addReverseRelation", function(request, response) {
// 	Parse.Cloud.useMasterKey();

// 	var eventsArray = request.params.eventsArray;
// 	var relatedEvent = request.params.relatedEvent;

// 	for (i = 0; i < eventsArray.length; i++) {
// 		var reverseEvent = eventsArray[i];
// 		var reverseRelation = reverseEvent.relation("possibleRelatedEvents");
// 		reverseRelation.add(relatedEvent);
// 		reverseEvent.save();
// 	}
// });

