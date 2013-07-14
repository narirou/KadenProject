/* ========================

	Lugve System

 ======================== */
class LugveSystem {

	ParticleSystem ps;
	LedSystem ls;

	int system;
	int LED_SYSTEM = 0;
	int PARTICLE_SYSTEM = 1;

	// Switch
	boolean switchFlag = true;

	// Position
	float x;
	float y;
	float targetX;
	float targetY;

	// Size number
	int num = 2;

	// Particle Size
	int[] partSizes = { 0, 70, 110, 140, 160, 190 };
	int partSize = partSizes[ num ];
	int partTargetSize = 0;

	// Led Size
	int[] ledSizes = { 0, 20, 30, 40, 50, 60 };
	int ledSize = ledSizes[ num ];
	int ledTargetSize = 0;

	// counter
	int count = 0;
	int countSize = 0;

	int DURATION_MOVE = 200;
	int DURATION_RESIZE = 100;

	LugveSystem() {
		system = PARTICLE_SYSTEM;

		ls = new LedSystem( 32, 24 );
		ps = new ParticleSystem( 70 );

		x = width / 2;
		y = height / 2;

		setLight( "ON" );
	}

	float easing( int count, int duration ) {
		return sin( HALF_PI / duration * ( duration - count ) );
	}

	public void update() {

		if( ! switchFlag && countSize == 0 ) return;

		ps.update();

		if( count > 0 ) {
			float ease = easing( count, DURATION_MOVE );
			x += ease * ( targetX - x );
			y += ease * ( targetY - y );
			count--;
		}

		if( countSize > 0 ) {
			float ease = easing( countSize, DURATION_RESIZE );
			ledSize += ease * ( ledTargetSize - ledSize );
			partSize += ease * ( partTargetSize - partSize );
			countSize--;
		}

		if( system == LED_SYSTEM ) {
			ls.setSize( ledSize );
			ls.setPos( x, y );
		}
		else if( system == PARTICLE_SYSTEM ) {
			ps.setSize( partSize );
			ps.setPos( x, y );
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

	// Mode
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

	// Switch
	public void toggleLight() {
		if( switchFlag ) {
			switchFlag = false;
			partTargetSize = partSizes[ 0 ];
			ledTargetSize = ledSizes[ 0 ];
			countSize = DURATION_RESIZE;
			println( "light : OFF" );
		}
		else {
			switchFlag = true;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
			println( "light : ON" );
		}
	}

	public void setLight( String message ) {
		if( message == "OFF" ) {
			switchFlag = false;
			partTargetSize = partSizes[ 0 ];
			ledTargetSize = ledSizes[ 0 ];
			countSize = DURATION_RESIZE;
			println( "light : OFF" );
		}
		else if( message == "ON" ){
			switchFlag = true;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
			println( "light : ON" );
		}
		else{
			println( "light : error" );
		}
	}

	public boolean getStatus() {
		return switchFlag;
	}

	// Size
	public void setSize( int n ) {
		if( ! switchFlag ) return;

		if( 0 <= n && n < partSizes.length ){
			num = n;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
		}
		println( "size : " + num );
	}

	public void sizeDown() {
		if( ! switchFlag ) return;

		if( 0 < num ) {
			num--;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
		}
		println( "size : " + num );
	}

	public void sizeUp() {
		if( ! switchFlag ) return;

		if( num < partSizes.length - 1 ) {
			num++;
			partTargetSize = partSizes[ num ];
			ledTargetSize = ledSizes[ num ];
			countSize = DURATION_RESIZE;
		}
		println( "size : " + num );
	}

	public void setPos( float inputX, float inputY ) {
		if( ! switchFlag ) return;

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
		println( "move : [ " + x + ", " + y + " ]" );
	}
};
