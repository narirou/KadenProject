import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import SimpleOpenNI.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class KadenProject extends PApplet {

/* ================================================

	LUGVE Processing Sample

	2013-07-06 | KADEN PROJECT :: SWITCH

	Credits:
		- Particles
		  by Daniel Shiffman
		- SimpleOpenNI Hands3d Test
		  by Max Rheiner, Interaction Design, zhdk

 ================================================ */




SimpleOpenNI context;

// Hand Controller
HandController hand;

// Lugve System
LugveSystem lugve;


/* ========================

	Setup

 ======================== */
public void setup() {

	size( 1024, 768, OPENGL );

	lugve = new LugveSystem();

	hand = new HandController();

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
	context.setSmoothingHands( 1.0f );

	hint( DISABLE_DEPTH_MASK );
}

/* ========================

	Draw

 ======================== */
public void draw() {

	background( 15 );

	lugve.update();
	lugve.display();

	context.update();

	hand.display();
}

/* ========================

	Mouse

 ======================== */
public void mousePressed() {

	switch( mouseButton ) {
		case LEFT:
			lugve.setPos( mouseX, mouseY );
		break;
	}
}

/* ========================

	Key

 ======================== */
public void keyPressed() {

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
		lugve.setSize( PApplet.parseInt( key - '0' ) );
	}
	else if( key == ' ' ) {
		lugve.toggleSystem();
	}
}


/* ========================

	Hands

 ======================== */
public void onCreateHands( int handId, PVector pos, float time ) {

	println( "onCreateHands - handId: " + handId + ", pos: " + pos + ", time:" + time );

	hand.createHands( pos );
}

public void onUpdateHands( int handId, PVector pos, float time ) {

	// println( "onUpdateHandsCb - handId: " + handId + ", pos: " + pos + ", time:" + time );

	hand.updateHands( pos );

	// Move Light
	if( hand.isStop( time ) && hand.isTrack() ) {
		float x = pos.x + width/2;
		float y =  height - ( pos.y + height/2 );
		lugve.setPos( x , y );
	}
}

public void onDestroyHands( int handId,float time ) {

	println( "onDestroyHandsCb - handId: " + handId + ", time:" + time );

	hand.destroyHands();
}


/* ========================

	Gesture

 ======================== */
public void onRecognizeGesture( String strGesture, PVector idPosition, PVector endPosition ) {

	println( "onRecognizeGesture - strGesture: " + strGesture + ", idPosition: " + idPosition + ", endPosition:" + endPosition );

	hand.recognizeGesture( strGesture, idPosition, endPosition );
}

public void onProgressGesture( String strGesture, PVector position,float progress ) {

	println("onProgressGesture - strGesture: " + strGesture + ", position: " + position + ", progress:" + progress);
}


/* ========================

	Hand Controller

 ======================== */
class HandController {

	boolean trackFlag;
	boolean moveFlag;

	float lastStopTime;

	PVector handVec = new PVector();
	ArrayList handVecList = new ArrayList();

	String lastGesture = "";

	int LIST_SIZE = 10;
	int DOT_STEPS = 8;

	HandController() {
		trackFlag = false;
		moveFlag = true;
	}

	public void display() {
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

	public void createHands( PVector pos ) {
		trackFlag = true;
		handVec = pos;

		handVecList.clear();
		handVecList.add( pos );
	}

	public void updateHands( PVector pos ) {
		handVec = pos;

		handVecList.add( 0, pos );

		if( handVecList.size() >= LIST_SIZE ) {
			handVecList.remove( handVecList.size() - 1 );
		}
	}

	public boolean isStop( float time ) {
		PVector curr = (PVector) handVecList.get( 1 );
		PVector last = (PVector) handVecList.get( handVecList.size() - 2 );
		float diffX = abs( curr.x - last.x );
		float diffY = abs( curr.y - last.y );
		float diffTime = abs( time - lastStopTime );

		if( diffX < 1.0f && diffY < 1.0f && trackFlag ) {

			if( diffTime > 1.0f && moveFlag ) {

				lastStopTime = time;
				moveFlag = false;

				return true;
			}
			moveFlag = false;
		}
		else {
			moveFlag = true;
		}
		return false;
	}

	public void destroyHands() {
		trackFlag = false;
		context.addGesture( lastGesture );
	}

	public void recognizeGesture( String strGesture, PVector idPosition, PVector endPosition ) {
		lastGesture = strGesture;
		context.removeGesture( strGesture );
		context.startTrackingHands( endPosition );
	}

	public boolean isTrack() {
		return trackFlag;
	}

	public ArrayList getHandVecList() {
		return handVecList;
	}
};
/* ========================

	Led System

 ======================== */
class LedSystem {

	float ledX;
	float ledY;
	float ledSize;
	float ledBaseSize;
	int intensity;

	LedSystem() {
		ledBaseSize = 100;
		intensity = 2;
	}

	public void setEmitter( float x, float y ) {
		ledX = x;
		ledY = y;
	}

	public void setSize( float size ) {
		if( ledSize == size ) return;
		ledSize = size;
	}

	public void display() {
		pushStyle();
			fill( 255 ,255, 250, 80 );

			for( int i = 1; i < 24; i++ ) {
				for( int t=1; t < 32; t++ ) {

					intensity = PApplet.parseInt( ledSize - ( dist( 32*t, 32*i, ledX, ledY ) / 5 ) );
					if( intensity < 2 ) intensity = 2;
					strokeWeight( intensity );
					stroke( 251, 201, 85, intensity );
					ellipse( 32 * t, 32 * i, intensity, intensity );
				}
			}
		popStyle();
	}
};

/* ========================

	Lugve System

 ======================== */
class LugveSystem {

	ParticleSystem ps;
	LedSystem ls;

	int system;
	int LED_SYSTEM = 0;
	int PARTICLE_SYSTEM = 1;

	// Position
	float x;
	float y;
	float targetX;
	float targetY;

	// Particle Size
	int[] partSizes = { 20, 50, 100, 150, 200, 250 };
	float partSize;
	float partTargetSize;

	// Led Size
	int[] ledSizes = { 10, 20, 30, 40, 50, 60 };
	float ledSize;
	float ledTargetSize;

	// Size number
	int num = 2;

	// counter
	int count = 0;
	int countSize = 0;

	int DURATION_MOVE = 200;
	int DURATION_RESIZE = 100;

	LugveSystem() {
		system = LED_SYSTEM;

		ps = new ParticleSystem( 70 );
		ls = new LedSystem();

		partSize = partSizes[ num ];
		ledSize = ledSizes[ num ];

		x = width / 2;
		y = height / 2;
		targetX = width / 2;
		targetY = height / 2;
	}

	public void update() {
		if( count > 0 ) {
			float ease = easing( count, DURATION_MOVE );
			x += ease * ( targetX - x );
			y += ease * ( targetY - y );
			count--;
		}

		if( countSize > 0 ) {
			float ease = easing( countSize, DURATION_RESIZE );
			partSize += ease * ( partTargetSize - partSize );
			ledSize += ease * ( ledTargetSize - ledSize );
			countSize--;
		}

		ps.update();

		if( system == LED_SYSTEM ) {
			ls.setEmitter( x, y );
			ls.setSize( ledSize );
		}
		else if( system == PARTICLE_SYSTEM ) {
			ps.setEmitter( x, y );
			ps.setSize( partSize );
		}
	}

	public void display() {
		if( system == LED_SYSTEM ) {
			ls.display();
		}
		else if( system == PARTICLE_SYSTEM ) {
			ps.display();
		}
	}

	public void toggleSystem() {
		if( system == LED_SYSTEM ) {
			system = PARTICLE_SYSTEM;
		}
		else if( system == PARTICLE_SYSTEM ) {
			system = LED_SYSTEM;
		}
	}

	public int getSystem() {
		return system;
	}

	public void setSystem( int inputSystem ) {
		if( inputSystem == LED_SYSTEM ) {
			system = LED_SYSTEM;
		}
		else if( inputSystem == PARTICLE_SYSTEM ) {
			system = PARTICLE_SYSTEM;
		}
	}

	public void setSize( int n ) {
		if( 0 < n && n < partSizes.length ){
			num = n;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
		}
	}

	public void setSizeDown() {
		if( num > 0 ) {
			num--;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
		}
	}

	public void setSizeUp() {
		if( num < partSizes.length - 1 ) {
			num++;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
		}
	}

	public void setPos( float inputX, float inputY ) {
		if( inputX > width ) {
			targetX = width;
		}
		else if( inputX < 0 ) {
			targetX = 0;
		}
		else{
			targetX = inputX;
		}
		if( inputY > height ) {
			targetY = height;
		}
		else if( inputY < 0 ) {
			targetY = 0;
		}
		else{
			targetY = inputY;
		}
		count = DURATION_MOVE;
	}

	public float easing( int count, int duration ) {
		return sin( HALF_PI / duration * ( duration - count ) );
	}
};
/* ========================

	Particle

 ======================== */
class Particle {

	PShape part;
	float partSize;
	float partBaseSize = 100;
	float partScale = 1;
	float lifespan = 0;
	PVector velocity;
	PVector gravity = new PVector( random(-0.1f,0.1f), random(-0.1f,0.1f) );
	PImage sprite;

	Particle() {
		// texture
		sprite = loadImage( "sprite.png" );

		// particle
		partSize = partBaseSize;
		part = createShape();
		part.beginShape( QUAD );
		part.noStroke();
		part.texture( sprite );
		part.normal( 0, 0, 0 );
		part.vertex( -partSize/2, -partSize/2, 0, 0 );
		part.vertex( +partSize/2, -partSize/2, sprite.width, 0 );
		part.vertex( +partSize/2, +partSize/2, sprite.width, sprite.height );
		part.vertex( -partSize/2, +partSize/2, 0, sprite.height );
		part.endShape();

		rebirth( 0, height + 300 );
		lifespan = random( 10 );
	}

	public PShape getShape() {
		return part;
	}

	public void rebirth( float x, float y ) {
		float angle = random( TWO_PI );
		float speed = random( 3, 4 );

		velocity = new PVector( cos( angle ), sin( angle ) );
		velocity.mult( speed );

		// particle life
		lifespan = random( PApplet.parseInt( partSize / 10 ) );

		part.resetMatrix();
		part.translate( x, y );
	}

	public void resize( float size ) {
		if( partSize == size ) return;

		float partScale = size / partSize;

		for( int i = 0, len = part.getVertexCount(); i < len ; i++ ) {
			PVector vec = part.getVertex( i );
			vec.x *= partScale;
			vec.y *= partScale;
			part.setVertex( i, vec );
		}
		partSize = size;
	}

	public boolean isDead() {
		return lifespan < 0 ? true : false;
	}

	public void update() {
		lifespan--;
		velocity.add( gravity );
		part.setTint( color( 251, 201, 85, lifespan * 2 + 10 ) );
		part.translate( velocity.x, velocity.y );
	}
};
/* ========================

	Particle System

 ======================== */
class ParticleSystem {

	ArrayList<Particle> particles;

	PShape particleShape;

	ParticleSystem( int n ) {
		particles = new ArrayList<Particle>();
		particleShape = createShape( PShape.GROUP );

		for ( int i = 0; i < n; i++ ) {
			Particle p = new Particle();
			particles.add( p );
			particleShape.addChild( p.getShape() );
		}
	}

	public void update() {
		for ( Particle p : particles ) {
			p.update();
		}
	}

	public void setEmitter( float x, float y ) {
		for ( Particle p : particles ) {
			if ( p.isDead() ) {
				p.rebirth( x, y );
			}
		}
	}

	public void setSize( float size ) {
		for ( Particle p : particles ) {
			p.resize( size );
		}
	}

	public void display() {
		shape( particleShape );
	}
};

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "KadenProject" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
