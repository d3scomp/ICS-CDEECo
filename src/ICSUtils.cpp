#include "ICSUtils.h"

void VehicleInterface::setSpeed(float speed) {};

bool VehicleInterface::isInteligentModeSupported() {
	return true;
};

/*Position VehicleInterface::getPosition() {
	return {42, 43};
};*/

Time GetCurrentTimeMs() {
	// TODO: Implement this
	return 0;
}

Distance getCrossingDistance(VehicleInterface::Position position, CrossingId) {
	return 0;
}