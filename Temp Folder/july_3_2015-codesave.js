require('cloud/app.js');
var _ = require('underscore');
var moment = require('cloud/moment.js');
var USGSQuakes = Parse.Object.extend("USGSQuakes");
var PubNub = require('cloud/pubnub.js');
var pubnub = {
  'publish_key' : 'pub-c-4fd8c17f-482b-4a3f-bd5d-1f326d809f0a',
  'subscribe_key' : 'sub-c-3f98a0c2-e6e3-11e4-a30c-0619f8945a4f'
};

Parse.Cloud.job('usgsJob', function(request, status) {
  return Parse.Cloud.httpRequest({
    url: 'http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson'
  }).then(function(httpResponse) {
    var jsonResponse = httpResponse.text;
    var someJSON = JSON.parse(httpResponse.text);
    
    var listArray = [];
    console.log("Running usgsJob cloud code...");

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
        console.log("Inside usgsJob - SAVED ALL!");
        promises.push(objs);
        Parse.Cloud.run("fetchQuakeDetails", objs);
      },
      error: function(error){
        console.log("Inside usgsJob - ERROR WHILE SAVING - "+error);
      }
    });

  return Parse.Promise.when(promises);
  
  }).then(function() {
    // Parse.Cloud.run("fetchQuakeDetails", listArray);
    status.success("Inside usgsJob - Saving completed successfully."); 
  }, function(error) {
    status.error("Inside usgsJob - Uh oh, something went wrong");
  });
});

Parse.Cloud.define("fetchQuakeDetails", function(request, response){
  console.log("Inside fetchQuakeDetails " + request.params.objs);
  // return Parse.Cloud.httpRequest({
  //  url:
  // })
});

Parse.Cloud.beforeSave("USGSQuakes", function(request, response) {
  Parse.Cloud.useMasterKey();

  if(!request.object.isNew()){
    // Let existing object updates go through
    // console.log("Inside USGSQuakes.beforeSave - !request.object.isNew(). Let existing object updates go through.");
    response.success();
  }

  var quakeLatitude = request.object.get("latitude");
  var quakeLongitude = request.object.get("longitude");
  var username = "emilypriddy";
  Parse.Cloud.httpRequest({
    url: "api.geonames.org/countrySubdivisionJSON?lat=" + quakeLatitude + "&lng=" + quakeLongitude + "&username=" + username
  }).then(function(httpResponse) {
    // success
    var jsonResponse = httpResponse.text;
    var someJSON = JSON.parse(httpResponse.text);

    var quakeProducts = someJSON.properties.products;
    var quakeGeoserveProperties = quakeProducts.geoserve[0].properties;

    var quakeCountry = quakeGeoserveProperties.country;
    var quakeState = quakeGeoserveProperties.state;

    request.object.set("country", quakeCountry);
    request.object.set("state", quakeState);

    console.log(httpResponse.text);
  }, function(httpResponse) {
    // error
    console.error('Request failed with response code ' + httpResponse.status);
  });

  var query = new Parse.Query(USGSQuakes);



  // Add query filters to check for uniqueness
  query.equalTo("usgsId", request.object.get("usgsId"));
  query.first().then(function(existingObject){
    if(existingObject){
      // Update existing object
      // console.log("Inside USGSQuakes.beforeSave - if(existingObject) - Update existing object.");
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
      // console.log("Inside USGSQuakes.beforeSave - else(!existingObject) - Parse.Promise.as(false)");
      // Pass a flag that this is not an existing object
      return Parse.Promise.as(false);
    }
  }).then(function(existingObject){
    if(existingObject){
      // Existing object, stop initial save
      // console.log("Inside USGSQuakes.beforeSave - Existing object. Stopping initial save.");
      response.error("Inside USGSQuakes.beforeSave - Existing object. Stopping initial save.");
    } else {
      // New object, let the save go through
      // console.log("Inside USGSQuakes.beforeSave - New object, let the save go through.");
      response.success();
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

  // Temporarily setting the quakeState and quakeChannel vars to "OK" to test other parts of this code.
  var quakeCountry = "United States";
  var quakeState = "Oklahoma";
  var quakeChannel = 'Oklahoma';

  // Find all UserEvent objects that were created within 100 miles of this USGSQuakes object and that have not already been assigned to a USGSQuake.
  var UserEvent = Parse.Object.extend("UserEvent");
  var userEventQuery = new Parse.Query(UserEvent);
  userEventQuery.withinMiles("userLocation", quakeLocation, 100.0);
  var userEventsArray = [];
  userEventQuery.notEqualTo("eventFound", "true");
  userEventQuery.find({
    success: function(userEventObjs){
      for (i=0; i < userEventObjs.length; i++){
        var userEventObj = userEventObjs[i];
        var userObj = userEventObj.get("user");
        feltByUsersRelation.add(userObj);
        userEventRelation.add(userEventObj);
        userEventObj.set("eventFound", "true");
        userEventObj.set("relatedQuake", quake);
        userEventObj.set("relatedQuakeId", quake.id);
        userEventsArray.push(userEventObj);
      }
      Parse.Object.saveAll(userEventsArray, {
        success: function(objs) {
          console.log("Saving all userEventObjs!");
        },
        error: function(error) {
          console.log("Error saving all userEventObjs!");
        }
      });
    },
    error: function(error){
      console.log("Inside USGSQuakes.afterSave - Error finding nearby users! " + error.message);
    }
  }).then(function() {
    console.log("Inside USGSQuakes.afterSave - completed successfully!!");
  }, function(error){
    console.log("Inside USGSQuakes.afterSave - Uh oh, something went wrong! - " + error.message);
  });

  // If a push notification has not been sent out for this earthquake send one out and set the pushSent flag to true.
  if (!pushStatus || pushStatus === undefined) {
    quake.save({
      pushSent: true
    }, {
      success: function(quake) {
        
        var pushUserEventQuery = new Parse.Query(UserEvent);
        pushUserEventQuery.withinMiles("userLocation", quakeLocation, 100.0);
        pushUserEventQuery.equalTo("relatedQuakeId", quake.id);
        pushUserEventQuery.find().then(function(objects){
          var promises = [];
          for (i = 0; i < objects.length; i++) {
            var userQuery = new Parse.Query(Parse.User);
            var userEvent = objects[i];
            userQuery.equalTo("objectId", userEvent.get('user').id);
            var pushQuery = new Parse.Query(Parse.Installation);
            pushQuery.matchesQuery('user', userQuery);

            promises.push(Parse.Push.send({
              where: pushQuery,
              data: {
                alert: quakeTitle + " " + userEvent.id,
                badge: "Increment",
                category: "DidYouFeelItEventCategory",
                qid: quakeUsgsId
              }
            }, {
              success: function(){
                // Push was successful!
              },
              error: function(error) {
                // Push failed!
              }}));
          }
          return Parse.Promise.when(promises);
        });

      }, // end success: function(quake)
      error: function(quake, error){
        // The save failed
        console.log("The save inside USGSQuakes.afterSave failed. " + error.message);
      } // end error: function(quake, error)
    }).then(function(){
      // var relatedUserEventsQuery = new Parse.Query("UserEvent");
    }); // end quake.save()
  } // end if (!pushStatus || pushStatus === undefined) {}
});

Parse.Cloud.define("changeUserEventFound", function(request, response){

});

