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
	PVector gravity = new PVector( random(-0.1,0.1), random(-0.1,0.1) );
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

		rebirth( width/2, height/2 );
		lifespan = random( 10 );
	}

	PShape getShape() {
		return part;
	}

	void rebirth( float x, float y ) {
		float angle = random( TWO_PI );
		float speed = random( 3, 4 );

		velocity = new PVector( cos( angle ), sin( angle ) );
		velocity.mult( speed );

		// particle life
		lifespan = random( int( partSize / 10 ) );

		part.resetMatrix();
		part.translate( x, y );
	}

	void resize( float size ) {
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

	boolean isDead() {
		return lifespan < 0 ? true : false;
	}

	void update() {
		lifespan--;
		velocity.add( gravity );
		part.setTint( color( 251, 230, 198, lifespan * 2 + 10 ) );
		part.translate( velocity.x, velocity.y );
	}
};
