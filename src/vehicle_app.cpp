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

	// Vehicle component
	auto vehicleInterface = new VehicleInterface();
	auto vehicle = new Vehicle::Component(*system, uniqId, *vehicleInterface);

	// Caches
	auto icsCache = new CDEECO::KnowledgeCache<ICS::Component::Type, ICS::Knowledge, 10>();
	system->registerCache(icsCache);

	// Ensembles
	new SpeedExchange::Ensemble(*vehicle, *icsCache);
}