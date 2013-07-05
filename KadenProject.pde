/* ================================================

	LUGVE Processing Example

	2013-07-06 | KADEN PROJECT :: SWITCH

	Credits:
		- Particles
		  by Daniel Shiffman
		- SimpleOpenNI Hands3d Test
		  by Max Rheiner, Interaction Design, zhdk

 ================================================ */

import java.util.*;
import SimpleOpenNI.*;

SimpleOpenNI context;

// Hand Controller
HandController hand;

// Lugve System
LugveSystem lugve;


void setup() {
	size( 1024, 768, OPENGL );

	lugve = new LugveSystem();

	hand = new HandController(); // using context

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

void draw() {
	background( 15 );

	lugve.update();
	lugve.display();
	context.update();
	hand.display();
}

/* ========================

	Mouse Event

 ======================== */
void mousePressed() {

	switch( mouseButton ) {
		case LEFT:
			lugve.setPos( mouseX, mouseY );
		break;
	}
}

/* ========================

	Key Event

 ======================== */
void keyPressed() {

	if( key == CODED ) {
		switch( keyCode ) {
			case UP:
				lugve.sizeUp();
			break;
			case DOWN:
				lugve.sizeDown();
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

	Hands Event

 ======================== */
void onCreateHands( int handId, PVector pos, float time ) {

	println( "onCreateHands - handId: " + handId + ", pos: " + pos + ", time:" + time );

	hand.createHands( pos );
}

void onUpdateHands( int handId, PVector pos, float time ) {

	hand.updateHands( pos );

	// Move Light
	if( hand.isStop( time ) && hand.isTrack() ) {

		float x = pos.x + width/2;
		float y =  height - ( pos.y + height/2 );

		lugve.setPos( x , y );
	}
}

void onDestroyHands( int handId,float time ) {

	println( "onDestroyHandsCb - handId: " + handId + ", time:" + time );

	hand.destroyHands();
}

void onRecognizeGesture( String strGesture, PVector idPosition, PVector endPosition ) {

	println( "onRecognizeGesture - strGesture: " + strGesture + ", idPosition: " + idPosition + ", endPosition:" + endPosition );

	hand.recognizeGesture( strGesture, idPosition, endPosition );
}

void onProgressGesture( String strGesture, PVector position,float progress ) {

	println("onProgressGesture - strGesture: " + strGesture + ", position: " + position + ", progress:" + progress );
}
