/* ============================================

	LUGVE Processing Example

	2013 | KADEN PROJECT :: SWITCH

	Credits:
		- Particles
		  by Daniel Shiffman
		- SimpleOpenNI Hands3d Test
		  by Max Rheiner, Interaction Design, zhdk

 ============================================= */

import java.util.*;
import processing.serial.*;
import SimpleOpenNI.*;

// Hand Controller
SimpleOpenNI context;

HandController hand;

// Lugve System
LugveSystem lugve;

// Arduino
Serial port;

Arduino arduino;

// Window
int WINDOW_WIDTH = 1024;
int WINDOW_HEIGHT = 768;

void setup() {
	size( WINDOW_WIDTH, WINDOW_HEIGHT, OPENGL );

	context = new SimpleOpenNI( this );

	if( context.enableDepth() == false ) {
		println( "Can't open the depthMap, maybe the camera is not connected!" );
		exit();
		return;
	}

	context.setMirror( true );
	context.enableHands();
	context.enableGesture();
	context.addGesture( "RaiseHand" );
	context.setSmoothingHands( 2.0 );

	hand = new HandController(); // using context

	port = new Serial( this, "COM3", 9600 );

	arduino = new Arduino( 15, 10 ); // using port

	lugve = new LugveSystem();

	hint( DISABLE_DEPTH_MASK );
}

void draw() {
	background( 15 );

	hand.update();
	hand.display();
	lugve.update();
	lugve.display();
}

/* ========================

	Mouse Event

 ======================== */
void mousePressed() {

	switch( mouseButton ) {
		case LEFT:
			lugve.setPos( mouseX, mouseY );
			arduino.setPos( mouseX, mouseY );
		break;
	}
}

/* ========================

	Key Event

 ======================== */
void keyPressed() {

	// Set Size
	if( keyCode == UP ) {
		lugve.sizeUp();
	}
	else if( keyCode == DOWN ) {
		lugve.sizeDown();
	}
	else if( '0' < key && key < '9' ) {
		lugve.setSize( int( key - '0' ) );
	}

	// ON / OFF
	else if( key == ENTER || key == RETURN ) {
		lugve.toggleLight();
	}

	// Change Mode
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
		float y =  height/2 - pos.y;

		lugve.setPos( x, y );
	}

	// Move Arduino LED
	if( hand.isTrack() ) {

		float x = pos.x + width/2;
		float y =  height/2 - pos.y;

		arduino.setPos( x, y );
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
