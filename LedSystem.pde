/* ========================

	Led System

 ======================== */
class LedSystem {

	float x;
	float y;
	int numX;
	int numY;
	float ledSize;
	float ledBaseSize;

	float DOT_STEP = 32;

	LedSystem( int inputNumX, int inputNumY ) {
		ledBaseSize = 100;
		numX = inputNumX;
		numY = inputNumY;
	}

	public void setPos( float inputX, float inputY ) {
		x = inputX;
		y = inputY;
	}

	public void setSize( float size ) {
		if( ledSize == size ) return;
		ledSize = size;
	}

	public void display() {
		pushStyle();
			fill( 255 ,255, 250, 80 );

			for( int i = 1; i < numX; i++ ) {
				for( int j = 1; j < numY; j++ ) {

					float ledX = DOT_STEP * i;
					float ledY = DOT_STEP * j;
					float distance = dist( ledX, ledY, x, y ) / 5;
					float intensity = int( ledSize - distance );
					if( intensity < 2 ) intensity = 2;

					strokeWeight( intensity );
					stroke( 251, 230, 198, intensity );
					ellipse( ledX, ledY, intensity, intensity );
				}
			}
		popStyle();
	}
};
