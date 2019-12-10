/***
* Name: finalProject0
* Author: Nico Catalano
* Description: 	wehfw	f�wf
* Tags: Tag1, Tag2, TagN
***/

model finalProject0


global {
	int doorSize<-6;
	int tableRadius<-3;
	
	point EntranceLocation <-{doorSize/2,doorSize/2};
	point ExitLocation <-{100-doorSize/2,doorSize/2};
	
	point StageLocation <- {85,85};
	point ChillLocation <- {15,85};
	point BarLocation <- {50,50};
	point securityLocation <- {3,50};
	
	point tableInitialPosion <- {30, 10};
	list<point> tablePositions;
	list<bool> tableBookings;
	//ture table booked, false not
	
	int  tableNumber <-3;
	
	init{
		//init table positions
		loop i from: 1 to: tableNumber { 
			add tableInitialPosion to:tablePositions;
			tableInitialPosion <- tableInitialPosion + {0, tableRadius*2.5};
			add false to:tableBookings;
			
			create Table number:1 {
				location <- tableInitialPosion;
			}
			
		}
		
		create Entrance number: 1{
			location <-EntranceLocation;
		}
		
		create Exit number: 1{
			location <- ExitLocation;
		}
		
		create Stage number: 1 {
				location <- StageLocation;
		}
		create ChillArea number: 1 {
				location <- ChillLocation;
		}
		create Bar number: 1 {
				location <- BarLocation;
		}
		
		create ChillGuest number: 5{
				location <- {rnd(50-10,50+10),rnd(50-10,50+10)};
		}
		create PartyGuest number: 5 {
				location <- {rnd(50-10,50+10),rnd(50-10,50+10)};
		}
		create Security number: 1 {
				location <- securityLocation;
		}
		
	}
	
}

species Guest  skills:[moving,fipa]{
	rgb guestColor <- #red;	
	point targetPoint <- nil;
	
	// Treats
	float drunkness <- 0.0;
	float talkative <- 0.0;
	float thirsty <- 0.0;
	float chill2dance <- 0.0;
	
	float danceTrashold <- 0.5;
	float thirstyTrashold <- 1.0;

	int status<-3;
	/*
	 * 0: want to drink
	 * 1: asked menu
	 * 2: received menu, ask for a drink
	 * 3: drinked, redy to go chill\dance;
	 * 4: wandering
	 */
	
	reflex moveToTarget when: targetPoint != nil {
		do goto target:targetPoint;
	}
	
	reflex updateThirsty when:thirsty<thirstyTrashold and status = 4 {
		//if (flip (0.1) = true){
		if(true){
			thirsty <- thirsty + rnd(0.0, 0.01);
			//thirsty <- thirsty + 0.3;
			//write name+ "thirsty:"+thirsty;
		}
	}
	
//	reflex introduceToBartender when:thirsty>=thirstyTrashold and location distance_to(BarLocation) < 0.5{
//		do start_conversation to: list(Bar) protocol: 'fipa-contract-net' performative: 'inform' contents: [drunkness] ;
//		thirsty<-0.0;
//		write name+ "ask the menu:"+thirsty color:#blue;
//	}

	reflex logTreats when:false{
		write "drunkness:"+drunkness +" thirsty:"+thirsty+ " status:"+status;
	}
	
	reflex askMenuBar when:status = 0 and thirsty>=thirstyTrashold and location distance_to(BarLocation) < 5{
		do start_conversation to: list(Bar) protocol: 'fipa-contract-net' performative: 'cfp' contents: [drunkness] ;
		
		thirsty<-0.0;
		status <- 1;
		write name+ "ask the menu:"+thirsty color:#blue;
	}
	
	reflex receivedMenu when:status = 1 and !empty(proposes) {
		message m <- proposes[0];
		list<string> menu <- (m.contents);
		
		int numElem <- length(menu);
		int selectedItem <- rnd(0,numElem-1);
		
		
		write name+"got menu:"+m.contents color:#purple;
		write name+"Selected:"+selectedItem color:#purple;
		status <- 2;
		do accept_proposal message:m contents: [selectedItem];
	}	
	

//	reflex logMessages {
//		loop c over:conversations{
//			write "conversation with:"+c;
//		}
//		loop m over:mailbox{
//			write "meesage::"+m;
//		}
//		write "proposes length:"+length(proposes) color:#pink;
//		write "is proposes not empty?:"+!empty(proposes) color:#pink;
//		
//		
//	}
	reflex selectBeverage when: status = 2 and !empty(informs){
		message m <- informs[0];
		float alchoolIncrement <- float(m.contents[0]);
		
		drunkness<- drunkness+alchoolIncrement;
		status <-3;
	}
	
	reflex imDrunk when:drunkness>=1{
		write name+"sono sbronzo!" color:#red;
	}
	
	reflex arrived2location when: targetPoint!= nil and location distance_to(targetPoint) < 1{
		targetPoint<-nil;
	}
	
	reflex dance when: status = 4{
		if (flip (chill2dance) = true){
			do wander;
		}
	}
	
    reflex goToStage when:status = 3 and chill2dance>= danceTrashold  and location distance_to(StageLocation) > 5 {
    	targetPoint<-StageLocation;
    	//write name + "belongs to party stage";
    }    
    
    reflex goToChill when:status = 3 and chill2dance< danceTrashold  and location distance_to(ChillLocation) > 5{
    	targetPoint<-ChillLocation;
    	//write name + "belongs to chill stage";
    }    
    
    reflex goToBar when:status  = 4 and thirsty>= thirstyTrashold {
    	targetPoint<-BarLocation;
    	status <-0;
    }
    
    reflex arrivedAtdanceFloor when:status = 3 and (location distance_to(StageLocation)<5 or location distance_to(ChillLocation)<5) {
    	status <- 4;
    }
     
    reflex SecurityInteraction when:status =1 and !empty(informs) and informs[0].sender = list(Security)[0]{
		message m <- informs[0];
	
		targetPoint<-m.contents[0];
		
    }
    
    reflex chackCondition when:false  and status=4{
    	write name+"status 4";
    }
    

    
    reflex mateReply when:status=5 and !empty(informs){
    	message m<-informs[0];
    	bool approchSuccess <- bool(m.contents[0]);
    
    	if(approchSuccess)	{
    		//going to the table
    		write name + " approach suceed message";
    		point myPosition <- m.contents[1];
    		targetPoint<-myPosition;
    		status <- 6;
    	}else{
    		write name + " recived failed approach";
			do end_conversation message:m contents:[];
			
			//unbook table
    		int bookedTableNumber <- int(m.contents[1]);
    		tableBookings[bookedTableNumber]<-false;
    		
    		status <- 4;
    	}
    }
    
  

    
    reflex lookingForMate when:status=4 and location distance_to(ChillLocation)<5 and tableBookings contains(false){
    	//write name+" I'm lookig for a mate! " color:#darkgreen;
    	
    	list<Guest> neighbourGuests <- (ChillGuest at_distance 10);
    	neighbourGuests<-shuffle(neighbourGuests);
    	    	
    	if(flip(talkative/10) and length(neighbourGuests)>0){
    		write name+" there are:"+length(neighbourGuests)+" potential mates";
    		Guest potentialMate <- neighbourGuests[0];
	    	write name+" found "+potentialMate color:#darkgreen;
	    	
    		bool tableStatus <- false;
    		
    		//booking table 
    		int tableIndex <-index_of(tableBookings,tableStatus);
    		tableBookings[tableIndex]<-true;
    		
    		
	    	write name+" -> "+potentialMate +"lets go to table "+tableIndex color:#darkgreen;
    		
    		point myPosition <- tablePositions[tableIndex]-{tableRadius,0}+{0,2*tableRadius};
    		point partnerPosition <- tablePositions[tableIndex]+{tableRadius,0}+{0,2*tableRadius};
    		
    		//comunicating where to go
    		do start_conversation to: list(potentialMate) protocol: 'fipa-contract-net' performative: 'inform' contents: [partnerPosition,myPosition,tableIndex] ;
    		write name+"I had proposed table"+tableIndex;
    		status <- 5;
    	}
    	
    }
    
    //receive inform message by other guest, but i'm already busy talking
    reflex receivedApproachFailed when:status!=4 and !empty(informs) {//and list(Guest) contains informs[0].sender{
    	message m<- informs[0];
    	int bookedTableNumber <- int(m.contents[2]);
		write name+" sorry "+m.sender+" i'm already busy (status:"+status+")";
		write "proposed table:"+bookedTableNumber;
		do inform message:m contents:[false,bookedTableNumber];
    	
		
    }
    
    //receive inform message by other guest
    reflex receivedApproach when:status=4 and !empty(informs) {//and list(Guest) contains informs[0].sender{
    	message m<- informs[0];
		targetPoint<-m.contents[1];
		point matePoint<-m.contents[0];
		write name+": "+m.sender+" approached me, going to point:"+targetPoint;
		do inform message:m contents:[true,matePoint];
		status <- 6;
    }

 
    
    reflex logStatus when:false {
    	write name + "status:"+status;
    }

    //on the exit square
    reflex exitFestival when: location distance_to(ExitLocation)<1{
    	do die;
    }
    
    
    aspect default{
       	draw cone3D(1.3,2.3) at: location color: #slategray ;
    	draw sphere(0.7) at: location + {0, 0, 2} color: #salmon ;
    }
    
    	
} 

species ChillGuest parent: Guest{
	init{
		talkative <- rnd(0.0,1.0);
		chill2dance <- rnd(0.0,0.3);
	}
	
   	aspect default{
       	draw cone3D(1.3,2.3) at: location color: #slategray ;
    	draw sphere(0.7) at: location + {0, 0, 2} color: #blue ;
    }
}

species PartyGuest parent: Guest{
	init{
		talkative <- rnd(0.0,1.0);
		chill2dance <- rnd(0.4,1.0);
	}
	
   aspect default{
       	draw cone3D(1.3,2.3) at: location color: #slategray ;
    	draw sphere(0.7) at: location + {0, 0, 2} color: #red ;
    }
}


species Stage{	
	rgb myColor <- #red;
	
	reflex changeColor {
		myColor <- flip(0.5) ? rnd_color(100, 200) : rnd_color(100, 200);
	}
	
	aspect default{
		draw square(30) at: location color: myColor;
	}
}

species ChillArea{	
	rgb myColor <- #lightseagreen;
	
	aspect default{
		draw square(30) at: location color: myColor;
	}
}

species Bar skills:[fipa]{
	rgb myColor <- #greenyellow;
	int width <- 20;
	int length <- 10;
	//int height <- 10;
	int height <- 0;
	
	float drunknesThreshold <- 0.4;
	
	list<string> beverages  		<- ['Grappa', 'Montenegro', 'Beer', 'Wine','Soda', 'Cola', 'Juice', 'Julmust'];
	list<float> alchoolPercentage 	<- [	0.4, 	0.23, 		0.05, 	0.12,	0.0, 	0.0, 	0.0, 	0.0];
//	list<string> beverages  		<- ['Grappa', 'Montenegro', 'Beer', 'Wine','Soda', 'Cola', 'Juice', 'Julmust'];
//	list<float> alchoolPercentage 	<- [	0.9, 	0.93, 		0.95, 	0.92,	0.9, 	0.9, 	0.9, 	0.9];
//	
	reflex evaluateDrunkness when:!empty(cfps){
		message m<-cfps[0];
		Guest g<-m.sender;
		float userDrunkness <- m.contents[0];
		
		//drunk guest, signal to security
		if(userDrunkness>=drunknesThreshold){
			write "reporting "+g + "is drunk";
			write "location of "+g + "is"+g.location;
			do start_conversation to: list(Security) protocol: 'fipa-contract-net' performative: 'inform' contents: [g] ;
		}
		// guest not drunk, provide menu
		else{
			write name+" got asked the menu! providing:"+beverages color:#orange;	
			do reply message:m performative:"propose" contents:beverages;
		}
		
	}
	
//	reflex provideMenu when:!empty(cfps){
//		message m<-cfps[0];
//		write name+" message m sender:"+m color:#orange;
//		do reply message:m performative:"propose" contents:beverages;
//		write name+" got asked the menu! providing:"+beverages color:#orange;
//	}
	
	reflex serveDrink when:!empty(accept_proposals){
		message m <- accept_proposals[0];
		do inform message:m contents:[alchoolPercentage[int(m.contents[0])]];
	}
	aspect default{
		draw box(width, length, height) at: location color: myColor;
	}
}

species Security skills:[moving, fipa]{
	rgb myColor <- #red;
	Guest target <- nil;
	int status <- 0;
	
	/*
	 * status
	 * 0: in resting position
	 * 1: received report, going to target
	 * 2: said to target to leave
	 * 3: reached exit
	 */
	reflex changeColor{
		if myColor = #red {
			myColor<-#blue;
		}else{
			myColor <-#red;
		}
	}
	
	reflex initialPosition when: target=nil {
		do goto target: {3,50};
		status <- 0;
	}
	
	reflex gotReport when:status = 0 and !empty(informs){
		message m <- informs[0];
		Guest g<-m.contents[0];
		target<-g;
		
		status <- 1;
		
		write "got a report of :"+ g color:#pink;
	}
	
	reflex kickOff when:status=1 and target != nil and location distance_to(target) < 1 {
		do start_conversation to: [target] protocol: 'fipa-contract-net' performative: 'inform' contents: [ExitLocation] ;
		status <- 2;
	}
	reflex arriveToExit when: status =2 and location distance_to(ExitLocation) < 9 {
		target<-nil;
		status<-3;
		
	}
	reflex moveToTarget when: target != nil {
		do goto target:target;
	}
	
	aspect default{
		draw sphere(1.5) at:location color: myColor;
	}
	reflex logSecurity when:false{
		write "status:"+status;
	}
	
}

species Entrance{
	
	aspect default{
		draw square(doorSize) at: location color: #green;
	}
}

species Table{
	
	aspect default{
		draw circle(tableRadius) at: location color: #green;
	}
}

species Exit{
	
	aspect default{
		draw square(doorSize) at: location color: #red;
	}
}


experiment Festival type: gui {
	output {
		display map type: opengl {
			species Entrance;
			species Exit;

			species Stage;
			species ChillArea;
			species Bar;
			species Table;
			
			species ChillGuest;
			species PartyGuest;
			species Security;
		}
	}
}
