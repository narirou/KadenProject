/* ========================

	Led System

 ======================== */
class LedSystem {

	float ledX;
	float ledY;
	float ledSize;
	float ledBaseSize = 100;
	int intensity = 2;

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

					intensity = int( ledSize - ( dist( 32*t, 32*i, ledX, ledY ) / 5 ) );
					if( intensity < 2 ) intensity = 2;
					strokeWeight( intensity );
					stroke( 251, 201, 85, intensity );
					ellipse( 32 * t, 32 * i, intensity, intensity );
				}
			}
		popStyle();
	}
};

