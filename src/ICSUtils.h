#ifndef ICS_UTILS_H
#define ICS_UTILS_H

typedef long Time;
typedef long VehicleId;
typedef long CrossingId;
typedef float Distance;
typedef float Speed;

/**
 * Possible directions/vectors for passing the crossing
 */
enum Direction {
	NORTH_SOUTH,
	NORTH_EAST,
	NORTH_WEST,
	SOUTH_NORTH,
	SOUTH_EAST,
	SOUTH_WEST,
	WEST_EAST,
	WEST_NORTH,
	WEST_SOUTH,
	EAST_WEST,
	EAST_NORTH,
	EAST_SOUTH,

	COUNT,
	MIN = NORTH_SOUTH,
	MAX = EAST_SOUTH
};

/** Possible unit operation mode */
enum Mode {
	Automatic, Manual
};


const long LATENCY_THRESHOLD_MS = 20;

/**
 * Dummy vehicle interface
 */
class VehicleInterface {
public:
	typedef struct {
		double log;
		double lat;
	} Position;
	
	void setSpeed(float speed);
	bool isInteligentModeSupported();
	Position getPosition();
};

/**
 * Gets some global time information
 *
 * This time reference is used to judge data latency. For example GPS time can be used for this purpose.
 */
Time GetCurrentTimeMs();

Distance getCrossingDistance(VehicleInterface::Position position, CrossingId id);

#endif // ICS_UTILS_H
