/* ========================

	Led System

 ======================== */
class LedSystem {

	float x;
	float y;
	int numX;
	int numY;
	float gridWidth;
	float gridHeight;

	float ledSize;
	float ledBaseSize;

	LedSystem( int inputNumX, int inputNumY ) {
		ledBaseSize = 100;

		numX = inputNumX;
		numY = inputNumY;

		gridWidth = WINDOW_WIDTH / numX;
		gridHeight = WINDOW_HEIGHT / numY;
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

					float ledX = gridWidth * i;
					float ledY = gridHeight * j;
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
