/* ================================================

	LUGVE Processing Sample

	2013-07-06 | KADEN PROJECT :: SWITCH

	Credits:
		- Particles
		  by Daniel Shiffman
		- SimpleOpenNI Hands3d Test
		  by Max Rheiner, Interaction Design, zhdk

 ================================================ */

import java.util.*;
import SimpleOpenNI.*;

// Hand Controll
SimpleOpenNI context;
float lastMoveTime;

boolean moveFlag = true;
boolean trackFlag = false;

PVector handVec = new PVector();
ArrayList handVecList = new ArrayList();
int handVecListSize = 10;

String lastGesture = "";

int DOT_STEPS = 8;

// Lugve System
LugveSystem lugve;


/* ========================

	Setup

 ======================== */
void setup() {

	size( 1024, 768, OPENGL );

	lugve = new LugveSystem();

	context = new SimpleOpenNI( this );

	if( context.enableDepth() == false ) {
		 println( "Can't open the depthMap, maybe the camera is not connected!" );
		 exit();
		 return;
	}

	context.setMirror( true );

	context.enableGesture();
	context.enableHands();
	context.addGesture( "RaiseHand" );
	context.setSmoothingHands( 1.0 );

	hint( DISABLE_DEPTH_MASK );
}

/* ========================

	Draw

 ======================== */
void draw() {

	background( 15 );

	lugve.update();
	lugve.display();

	context.update();

	pushMatrix();
		translate( width/2, height/2, 0 );
		rotateX( radians( 180 ) );

		int[] depthMap = context.depthMap();
		int index;
		PVector realWorldPoint;

		// set the rotation center of the scene 1000 infront of the camera
		translate( 0, 0, -1000 );

		// draw the 3d point depth map
		pushStyle();
			strokeWeight( 2 );
			stroke( 100 );

			for( int y = 0; y < context.depthHeight(); y += DOT_STEPS ) {
				for( int x = 0; x < context.depthWidth(); x += DOT_STEPS ) {

					index = x + y * context.depthWidth();

					if( depthMap[ index ] > 0 ) {
						realWorldPoint = context.depthMapRealWorld()[ index ];
						point( realWorldPoint.x, realWorldPoint.y, realWorldPoint.z );
					}
				}
			}
		popStyle();

		// draw the tracked hand
		if( trackFlag ) {
			pushStyle();
				strokeWeight( 2 );
				stroke( 251, 201, 85, 80 );
				noFill();
				Iterator itr = handVecList.iterator();
				beginShape();
					while( itr.hasNext() ) {
						PVector p = (PVector) itr.next();
						vertex( p.x, p.y, p.z );
					}
				endShape();

				strokeWeight( 4 );
				stroke( 251,201,85 );
				point( handVec.x, handVec.y, handVec.z );
			popStyle();
		}
	popMatrix();
}

/* ========================

	Mouse Events

 ======================== */
void mousePressed() {

	switch( mouseButton ) {
		case LEFT:
			lugve.setPos( mouseX, mouseY );
		break;
	}
}

/* ========================

	Key Events

 ======================== */
void keyPressed() {

	if( key == CODED ) {
		switch( keyCode ) {
			case UP:
				lugve.setSizeUp();
			break;
			case DOWN:
				lugve.setSizeDown();
			break;
		}
	}
	else if( '0' < key && key < '9' ) {
		lugve.setSize( int( key - '0' ) );
	}
	else if( key == ' ' ) {
		lugve.toggleSystem();
	}
}


/* ========================

	Hand Events

 ======================== */
void onCreateHands( int handId, PVector pos, float time ) {

	println( "onCreateHands - handId: " + handId + ", pos: " + pos + ", time:" + time );

	trackFlag = true;
	handVec = pos;

	handVecList.clear();
	handVecList.add( pos );
}

void onUpdateHands( int handId, PVector pos, float time ) {

	// println( "onUpdateHandsCb - handId: " + handId + ", pos: " + pos + ", time:" + time );

	handVec = pos;

	handVecList.add( 0, pos );

	// remove the last point
	if( handVecList.size() >= handVecListSize ) {
		handVecList.remove( handVecList.size() - 1 );
	}

	// Move Light
	PVector last = (PVector) handVecList.get( handVecList.size() - 2 );
	float diffX = abs( pos.x - last.x );
	float diffY = abs( pos.y - last.y );
	float diffTime = abs( time - lastMoveTime );

	if( diffX < 1.0 && diffY < 1.0 && trackFlag ) {

		if( diffTime > 1.0 && moveFlag ) {

			float posX = pos.x + width/2;
			float posY =  height -  (pos.y + height/2 );

			println( "move : [ " + posX + " , " + posY + " ]" );

			lastMoveTime = time;
			lugve.setPos( posX , posY );
		}
		moveFlag = false;
	}
	else {
		moveFlag = true;
	}
}

void onDestroyHands( int handId,float time ) {

	println( "onDestroyHandsCb - handId: " + handId + ", time:" + time );

	trackFlag = false;
	context.addGesture( lastGesture );
}


/* ========================

	Gesture Events

 ======================== */
void onRecognizeGesture( String strGesture, PVector idPosition, PVector endPosition ) {

	println( "onRecognizeGesture - strGesture: " + strGesture + ", idPosition: " + idPosition + ", endPosition:" + endPosition );

	lastGesture = strGesture;
	context.removeGesture( strGesture );
	context.startTrackingHands( endPosition );
}

void onProgressGesture( String strGesture, PVector position,float progress ) {

	//println("onProgressGesture - strGesture: " + strGesture + ", position: " + position + ", progress:" + progress);
}
