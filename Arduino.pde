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

	public void setPos( float inputX, float inputY ){

		int gridX = int( inputX / gridWidth );
		int gridY = int( inputY / gridHeight );

		if( gridX < 0 ) {
			gridX = 0;
		}
		else if( gridX >= numX - 1 ) {
			gridX = numX - 1;
		}

		if( gridY < 0 ) {
			gridY = 0;
		}
		else if( gridY >= numY - 1 ) {
			gridY = numY - 1;
		}

		// Mirroring LED Light
		// 左右反転する
		gridX = ( numX - 1 ) - gridX;

		port.read();

		if( port.available() > 0 ) {
			port.write( gridX );
			port.write( gridY );

			println( "arduino : [ " + gridX + ", " + gridY + " ]" );
		}
	}
};
