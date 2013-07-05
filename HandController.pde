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
	int DOT_STEP = 8;

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

				for( int y = 0; y < context.depthHeight(); y += DOT_STEP ) {
					for( int x = 0; x < context.depthWidth(); x += DOT_STEP ) {

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

	public void destroyHands() {
		trackFlag = false;
		context.addGesture( lastGesture );
	}

	public void recognizeGesture( String strGesture, PVector idPosition, PVector endPosition ) {
		lastGesture = strGesture;
		context.removeGesture( strGesture );
		context.startTrackingHands( endPosition );
	}

	public boolean isStop( float time ) {

		if( ! trackFlag ) return false;

		PVector curr = (PVector) handVecList.get( 1 );
		PVector last = (PVector) handVecList.get( handVecList.size() - 2 );
		float diffX = abs( curr.x - last.x );
		float diffY = abs( curr.y - last.y );
		float diffTime = abs( time - lastStopTime );

		if( diffX < 1.0 && diffY < 1.0 ) {

			if( diffTime > 1.0 && moveFlag ) {

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

	public boolean isTrack() {
		return trackFlag;
	}

	public ArrayList getHandVecList() {
		return handVecList;
	}
};