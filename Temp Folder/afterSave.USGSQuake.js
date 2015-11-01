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
    console.log("Error performing checks or saves (console.log)");
    response.error("Error performing checks or saves.");
  });
});

Parse.Cloud.afterSave("USGSQuakes", function(request) {
  // Our "USGSQuakes" class has a "title" key with a summary of the quake.
  var quake = request.object;
  var pushStatus = quake.get('pushSent');
  if (!pushStatus || pushStatus === undefined) {
    quake.save({
      pushSent: true
    }, {
      success: function(quake) {
        // The object saved successfully, so send the push.
        var quakeTitle = quake.get('title');
        var quakeUSGSID = quake.get('usgsId');

        
        // Create a new channel on PubNub for this event and subscribe any users that received a push from this event to this channel.
        
        var q = new Parse.Query("USGSQuakes");
        q.count({ success: function(count) {
          console.log("total earthquakes in DB: " + count);
        }});

        var pushQuery = new Parse.Query(Parse.Installation);
        var nearbyPushQuery = new Parse.Query(Parse.Installation);
        var installationQuery = pushQuery.equalTo('channels', 'OK');
        console.log("installationQuery = " + installationQuery);
        //var jsonMsg = encodeURI(count);
      
        var channel = quakeUSGSID;
        var quake_channel = quakeUSGSID;
        console.log("channel = " + channel);        

        // Parse.Cloud.httpRequest({
        //   url: 'http://pubsub.pubnub.com/subscribe/sub-c-3f98a0c2-e6e3-11e4-a30c-0619f8945a4f/' + channel + '/0/0',
        //   success: function(httpResponse) {
        //     console.log('User with UUID ' + )
        //   }
        // });
        var message = {
          'from' : 'PubNub+Parse',
          'to' : 'installationQuery',
          'message' : 'Hello from quake channel ' + quake_channel
        }
        Parse.Cloud.httpRequest({
          // url: 'https://pubsub.pubnub.com/publish/pub-c-4fd8c17f-482b-4a3f-bd5d-1f326d809f0a/sub-c-3f98a0c2-e6e3-11e4-a30c-0619f8945a4f/0/' + channel + '/0/0',
          url: 'http://pubsub.pubnub.com/publish/' +
            pubnub.publish_key + '/' +
            pubnub.subscribe_key + '/0/' +
            quake_channel + '/0/' +
            encodeURIComponent(JSON.stringify(message))
          }).then(function(httpResponse) {
          	// success
          	console.log('publish from Cloud worked?' + httpResponse.text);
          }, function(httpResponse) {
          	// error
          	console.error('Request failed with response code ' + httpResponse.status);
          });
          // success: function(httpResponse) {
          //   console.log('Channel ' + channel + ' has been created! ' + httpResponse.text + ' Subscribed user with UUID: ');
          // },
          // error: function(httpResponse) {
          //   console.log('Request failed with response code ' + httpResponse.status);
          // }
        // });

        // pushQuery.equalTo('channels', 'OK').each({
        //   success: function(results) {
        //     console.log("Successfully retrieved " + results.length + " users.");
        //     for (var i=0; i < results.length; i++) {
        //       var installationId = results[i].get("installationId");
        //       console.log("User has installationId of " + installationId);
        //     }
        //   },
        //   error: function(error) {
        //     console.log("Error: " + error.code + " " + error.message);
        //   }
        // });
        
        // Send a push notification

        Parse.Push.send({
          where: pushQuery,
          data: {
            alert: quakeTitle,
            badge: "Increment",
            category: "DidYouFeelItEventCategory",
            qid: quakeUSGSID
          }
        }, {
          success: function(){
            // Push was successful
            console.log("Push was successful!");
          },
          error: function(){
            // Handle error
            console.log("Push failed!");
          }
        });
      },
      error: function(quake, error){
        // The save failed. 
        console.log("The save failed. "+error);
      }
    });
  }
});

// More recent 6/15/15

Parse.Cloud.afterSave("USGSQuakes", function(request, response) {
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
  // if (!quakeState) {
  //  quakeChannel = quakeCountry;
  // } else {
  //  quakeChannel = quakeState;
  // }

  // If a push has NOT been sent yet for this quake.
  if (!pushStatus || pushStatus === undefined) {

    var pushQuery = new Parse.Query(Parse.Installation);
    // var channelsQuery = installationQuery.equalTo('channels', quakeChannel);
    pushQuery.equalTo('channels', 'Oklahoma');
    // console.log('quakeChannel = ' + quakeChannel);
    // console.log('channelsQuery = ' + channelsQuery);
    console.log('pubnubChannel = ' + pubnubChannel);

    var cloudMessage = {
      'from' : 'PubNub+Parse',
      'to' : 'installationQuery',
      'message' : 'Hello from quakeChannel ' + quakeChannel + ' pubnubChannel ' + pubnubChannel
    };

    // Send a push notification

        Parse.Push.send({
          where: pushQuery,
          data: {
            alert: quakeTitle,
            badge: "Increment",
            category: "DidYouFeelItEventCategory",
            qid: quakeUsgsId
          }
        }).then(function() {
          quake.save({
            pushSent: true
          }).then(function() {
            console.log("Push sent to " + quakeChannel);

            Parse.Cloud.httpRequest({
              // url: 'https://pubsub.pubnub.com/publish/pub-c-4fd8c17f-482b-4a3f-bd5d-1f326d809f0a/sub-c-3f98a0c2-e6e3-11e4-a30c-0619f8945a4f/0/' + channel + '/0/0',
              url: 'http://pubsub.pubnub.com/publish/' +
                pubnub.publish_key + '/' +
                pubnub.subscribe_key + '/0/' +
                pubnubChannel + '/0/' +
                encodeURIComponent(JSON.stringify(cloudMessage))
              }).then(function(httpResponse) {
                // success
                console.log('publish from Cloud worked?' + httpResponse.text);
              }, function(httpResponse) {
                // error
                console.error('Request failed with response code ' + httpResponse.status);
              });
          }, function(error) {
            console.error("Error: " + error.code + " " + error.message);
          });
          console.log("Saving completed successfully."); 
        }, function(error) {
          console.error("Saving Error: " + error.code + " " + error.message);
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