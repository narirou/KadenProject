class Arduino{

	int numX;
	int numY;
	float gridWidth;
	float gridHeight;

	Arduino( int inputNumX, int inputNumY ) {

		numX = inputNumX;
		numY = inputNumY;

		gridWidth = WINDOW_WIDTH / numX;
		gridHeight = WINDOW_HEIGHT / numY;
	}

	public void setPos( float x, float y ){

		int w = int( x / gridWidth );
		int h = int( y / gridWidth );

		port.read();

		if( port.available() > 0 ) {
			port.write( w );
			port.write( h );

			println( "arduino : [ " + w + ", " + h + " ]" );
		}
	}
};
