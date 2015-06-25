{
    init: function(elevators, floors) {
        
        
        function getLowestLoadElevator(elevators){
            var lowest = elevators[0];
            var lowscore = 1.0;
            elevators.forEach(function(elevator){
                if (elevator.loadFactor() < lowscore){
                    lowscore = elevator.loadFactor();
                    lowest = elevator;
                }   
            })
            return lowest;
        }
        
        function isInArray(value, array){
            return array.indexOf(value) > -1;
        }
        
        /**
        function getBestElevatorOLD(elevators, floorNum){
            //var difference = 100;
            var difference = elevators[0].currentFloor() - floorNum;
            var closest = elevators[0];
            elevators.forEach(function(elevator){
                if (Math.abs(elevator.currentFloor() - floorNum) < difference && elevator.destinationQueue.length < 4 ){
                    difference = Math.abs(elevator.currentFloor() - floorNum)
                    closest = elevator;
                }
            })
            return closest;
        }
        **/
        
        // getBestElevator 2.0
        
        function getBestElevator(elevators,floorNum) {
            
            var elevatorDict = {};  
            
            // Default elevator
            best = elevators[0];
            
            elevators.forEach( function(elevator) {
                
                // Only choose non-full elevators 
                if (elevator.loadFactor() < 1) {
                    
                    // create a dict where k = elevator object and v = weight
                    elevatorDict[elevator] = elevator.destinationQueue.length + 
                                (Math.abs(floorNum - elevator.currentFloor()));
                }
            });
            
            elevators.forEach( function(elevator) {
               
               // Compare the weight of each elevator and select the best
               if (elevatorDict[elevator] < elevatorDict[best]) {
                   best = elevator;
               }
                
            });
            
            return best;
        }
        
        /** We don't want to remove all of the instances of a floor in the destination
         *  queue >IF< the floor is in pressedfloors(); however, we DO still want
         *  to remove superfluous entries. VVVVVVV
         **/
         
         
         
         
        
        function updateDestinationQueues(elevators, elevator, floorNum){
            elevators.forEach( function(e){
                if (e != elevator && e.destinationQueue.indexOf(floorNum) > -1 &&
                                e.getPressedFloors().indexOf(floorNum) < 0) {
                    var index = e.destinationQueue.indexOf(floorNum);
                    e.destinationQueue.splice(index, 1);
                    e.checkDestinationQueue();
                }
            });
        }
        
        
        
        elevators.forEach(function(elevator){
            elevator.on("floor_button_pressed", function(floorNum) {
                    if (elevator.loadFactor() >= 1) {
                        elevator.goToFloor(floorNum, true);
                    } else {
                        elevator.goToFloor(floorNum); 
                    }
                    
            });
            elevator.on("passing_floor", function(floorNum){
                if (isInArray(floorNum, elevator.destinationQueue) && elevator.loadFactor() < 1){
                   elevator.goToFloor(floorNum, true);
                   elevator.checkDestinationQueue();
                   updateDestinationQueues(elevators,elevator,floorNum);
                }
            });
            
            elevator.on("stopped_at_floor", function(floorNum) {
                while (elevator.destinationQueue.indexOf(floorNum) > -1) {
                    var index = elevator.destinationQueue.indexOf(floorNum);
                    elevator.destinationQueue.splice(index, 1);
                }
            });
            
            elevator.on("idle", function() {
                elevator.goToFloor(0);
            });
        });
        
        /*floors.forEach(function(floor) {
            floor.on("up_button_pressed down_button_pressed", function() {
                var elevator = elevators[1];
                if (elevator.destinationQueue.length < 3){
                    elevator.goToFloor(floor.level);
                }
            }); 
        });*/
        
        
        floors.forEach(function(floor) {
            floor.on("up_button_pressed down_button_pressed", function() {
                var elevator = getBestElevator(elevators, floor.floorNum());
                elevator.goToFloor(floor.floorNum());
            }); 
        });
        
    },
        update: function(dt, elevators, floors) {
            
            for (var i=0, il = dt.length; i < il; i++){
                alert(il[i]);
            }
            
            var closestFloor = floors[0];
            elevators.forEach(function(elevator) {
                if (elevator.loadFactor() >= 0.5) {
                    alert("It's full, trying to fix");
                    floors.forEach(function(floor) {
                       if (elevator.getPressedFloors().indexOf(floor.floorNum()) > -1) {
                            if (Math.abs(elevator.currentFloor() - floor.floorNum()) < 
                                Math.abs(elevator.currentFloor() - closestFloor.floorNum())) {
                                    closestFloor = floor;
                            }
                        }
                       
                       
                    });
                   
                    if (elevator.destinationQueue[0] != closestFloor.floorNum()) {
                        alert("Holy shit we're full");
                        elevator.goToFloor(closestFloor.floorNum(), true);
                        elevator.checkDestinationQueue();
                    }
                   
                };
            });
        }
}