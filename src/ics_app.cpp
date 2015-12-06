 /**
 * Setups the ICS CDEECo application
 */
 
#include <cstdint>

#include "MrfRadio.h"
#include "Vehicle.h"
#include "ICS.h"
#include "SpeedExchange.h"
 
void cdeecoSetup(const uint32_t uniqId) {
	//// System setup
	auto radio = new MrfRadio(0, uniqId, uniqId);
	auto system = new CDEECO::System<3, 64>(*radio);

	// ICS component
	auto ics = new ICS::Component(*system, uniqId);

	// Caches
	auto vehicleCache = new CDEECO::KnowledgeCache<Vehicle::Component::Type, Vehicle::Knowledge, 10>();
	system->registerCache(vehicleCache);

	// Ensembles
	new SpeedExchange::Ensemble(*ics, *vehicleCache);
}

