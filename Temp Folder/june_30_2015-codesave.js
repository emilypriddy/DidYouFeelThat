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
        response.success("Inside usgsJob - SAVED ALL!");
      },
      error: function(error){
        response.error("Inside usgsJob - ERROR WHILE SAVING - "+error);
      }
    });

  return Parse.Promise.when(promises);
  
  }).then(function() {
    response.success("Inside usgsJob - Saving completed successfully."); 
  }, function(error) {
    response.error("Inside usgsJob - Uh oh, something went wrong");
  });
});

Parse.Cloud.define("fetchQuakeDetails", function(request, response){
	console.log("Inside fetchQuakeDetails " + request.params.objs);
	// return Parse.Cloud.httpRequest({
	// 	url:
	// })
});

Parse.Cloud.beforeSave("USGSQuakes", function(request, response) {
	Parse.Cloud.useMasterKey();

  if(!request.object.isNew()){
    // Let existing object updates go through
    console.log("Inside USGSQuakes.beforeSave - !request.object.isNew(). Let existing object updates go through.");
    response.success();
  }
  var query = new Parse.Query(USGSQuakes);
  // Add query filters to check for uniqueness
  query.equalTo("usgsId", request.object.get("usgsId"));
  query.first().then(function(existingObject){
    if(existingObject){
      // Update existing object
      console.log("Inside USGSQuakes.beforeSave - if(existingObject) - Update existing object.");

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
      console.log("Inside USGSQuakes.beforeSave - else(!existingObject) - Parse.Promise.as(false)");
      // Pass a flag that this is not an existing object
      return Parse.Promise.as(false);
    }
  }).then(function(existingObject){
    if(existingObject){
      // Existing object, stop initial save
      console.log("Inside USGSQuakes.beforeSave - Existing object. Stopping initial save.");
      response.error("Inside USGSQuakes.beforeSave - Existing object. Stopping initial save.");
    } else {
    	var quake = request.object;
    	var quakeLocation = quake.get('location');
    	var userEventRelation = quake.relation('relatedUserEvents');
    	var feltByUsersRelation = quake.relation('feltByUsers');

    	console.log("QUAKE LOCATION.LATITUDE = " + quakeLocation.latitude);

    	var UserEvent = Parse.Object.extend("UserEvent");
			var userEventQuery = new Parse.Query(UserEvent);
			userEventQuery.withinMiles("userLocation", quakeLocation, 100.0);
			userEventQuery.notEqualTo("eventFound", "true");
			userEventQuery.find({
				success: function(userEventObjs){
					for (i=0; i < userEventObjs.length; i++){
						var userEventObj = userEventObjs[i];
						var userObj = userEventObj.get("user");
						console.log("Inside USGSQuakes.beforeSave - Found userEventObj.user.id = " + userObj.id);
						feltByUsersRelation.add(userObj);
						userEventRelation.add(userEventObj);
						console.log("Inside USGSQuakes.beforeSave - Found userEventObj.id: " + userEventObj.id);
						userEventObj.set("eventFound", "true");
						userEventObj.set("relatedQuake", quake);
						userEventObj.save();
					}
					
				},
				error: function(error){
					console.log("Inside USGSQuakes.beforeSave - Error finding nearby users! " + error.message);
				}
			}).then(function() {
				console.log("Inside USGSQuakes.beforeSave - completed successfully!!");
				response.success();
			}, function(error){
				console.log("Inside USGSQuakes.beforeSave - Uh oh, something went wrong! - " + error.message);
			});
      // New object, let the save go through
      console.log("Inside USGSQuakes.beforeSave - New object, let the save go through.");
    }
  }, function(error){
    response.error("Inside USGSQuakes.beforeSave - Error performing checks or saves.");
  });
});

Parse.Cloud.afterSave("USGSQuakes", function(request) {
	Parse.Cloud.useMasterKey();

	var quake = request.object;
	var quakeLocation = quake.get('location');
  var quakeTitle = quake.get('title');
  var quakeUsgsId = quake.get('usgsId');
  var userEventRelation = quake.relation('relatedUserEvents');
  var feltByUsersRelation = quake.relation('feltByUsers');
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
						console.log("Inside USGSQuakes.afterSave push to " + install.id + " - success!");

						var UserEvent = Parse.Object.extend("UserEvent");
						var userEventQuery = new Parse.Query(UserEvent);
						userEventQuery


					}, function(error) {
						console.log("Inside USGSQuakes.afterSave push to " + install.id + " - error: " + error.message);
					})); // end installations.push
		  	}); // end pushQuery.find()
		  }, // end success: function(quake)
		  error: function(quake, error){
		  	// The save failed
		  	console.log("The save inside USGSQuakes.afterSave failed. " + error.message);
		  }
		}).then(function(){
			// var relatedUserEventsQuery = new Parse.Query("UserEvent");
		}); // end quake.save()
	} // end if (!pushStatus || pushStatus === undefined) {}
});

Parse.Cloud.define("changeUserEventFound", function(request, response){


});

