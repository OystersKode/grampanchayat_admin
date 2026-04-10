import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedVehicles() async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference vehicles = db.collection('vehicles');

  final List<Map<String, dynamic>> driverData = [
    {
      "driver_name": "Sumit parit",
      "driver_phone": "9916939388",
      "area": "Kagwad",
      "vehicle_number": "MH06T6181",
      "vehicle_model": "Eritiga"
    },
    {
      "driver_name": "Anil Kallole",
      "driver_phone": "9620068200",
      "area": "Kagawd",
      "vehicle_number": "KA14A7185",
      "vehicle_model": "Cruiser"
    },
    {
      "driver_name": "Salim mahat",
      "driver_phone": "9886271072",
      "area": "Kagwad",
      "vehicle_number": "KA22Z4558",
      "vehicle_model": "Eritiga"
    },
    {
      "driver_name": "Shankar Nayak",
      "driver_phone": "9449151431",
      "area": "Kagwad",
      "vehicle_number": "KA29A0987",
      "vehicle_model": "Cruiser"
    },
    {
      "driver_name": "Dhanaraj Karav",
      "driver_phone": "9019962686",
      "area": "Kagwad",
      "vehicle_number": "Mh11aw5161",
      "vehicle_model": "Mahindra verito"
    },
    {
      "driver_name": "Mahesh Patil",
      "driver_phone": "9986878184",
      "area": "Kagwad",
      "vehicle_number": "KA22 N8475",
      "vehicle_model": "Cruiser Toofan"
    },
    {
      "driver_name": "Imran Makandar",
      "driver_phone": "9742552264",
      "area": "Kagwad",
      "vehicle_number": "MH17V7749",
      "vehicle_model": "Swift Dzire"
    },
    {
      "driver_name": "Sunil magadum",
      "driver_phone": "7411808567",
      "area": "Kagwad",
      "vehicle_number": "6957",
      "vehicle_model": "Alto"
    },
    {
      "driver_name": "Ravi mali",
      "driver_phone": "9686302577",
      "area": "Kagwad",
      "vehicle_number": "KA35A7907",
      "vehicle_model": "Force cruiser"
    },
    {
      "driver_name": "Raju Hulyal",
      "driver_phone": "8971222927",
      "area": "Shedbal",
      "vehicle_number": "KA23B1602",
      "vehicle_model": "Cruiser. Swift disear"
    },
    {
      "driver_name": "Shivaprasad ganiga",
      "driver_phone": "7996654944",
      "area": "Kagwad",
      "vehicle_number": "KA28N4918",
      "vehicle_model": "Indica Vista"
    },
    {
      "driver_name": "Pintu bhajantri",
      "driver_phone": "9380468354",
      "area": "Kagwad",
      "vehicle_number": "MH10CR1807",
      "vehicle_model": "Tata ase pikup"
    },
    {
      "driver_name": "Prashant khot",
      "driver_phone": "9844917177",
      "area": "Kagwad",
      "vehicle_number": "Ka23b9844",
      "vehicle_model": "Intra v50 100 kg to 5 ton load"
    },
    {
      "driver_name": "Mahavir khsirasagar",
      "driver_phone": "9986415872",
      "area": "Kagwad",
      "vehicle_number": "MH10CR3547",
      "vehicle_model": "TATA ase pickup"
    },
    {
      "driver_name": "Suresh pujari",
      "driver_phone": "8722508290",
      "area": "Kagwad",
      "vehicle_number": "Mh10cr0860",
      "vehicle_model": "Tata ace"
    },
    {
      "driver_name": "Swayam Patil",
      "driver_phone": "6363788985",
      "area": "Kagwad",
      "vehicle_number": "KA23A1850",
      "vehicle_model": "Tata ace"
    },
    {
      "driver_name": "Ramesh Hulyal",
      "driver_phone": "7349398672",
      "area": "Shedbal",
      "vehicle_number": "KA32N5943",
      "vehicle_model": "Swift Dzire 5sit"
    },
    {
      "driver_name": "Kiran shintre",
      "driver_phone": "8123480143",
      "area": "Ugar khurd",
      "vehicle_number": "KA22MA3653",
      "vehicle_model": "Ertiga"
    },
    {
      "driver_name": "Krishna Kamble",
      "driver_phone": "9035204522",
      "area": "Ugar khurd",
      "vehicle_number": "Ka23a9017",
      "vehicle_model": "Swift desire"
    },
    {
      "driver_name": "Pravin Kamble",
      "driver_phone": "7026492432",
      "area": "kagwad",
      "vehicle_number": "MH 04 GE9480",
      "vehicle_model": "Renault duster"
    },
    {
      "driver_name": "Kalappa sutar",
      "driver_phone": "8861298911",
      "area": "Mole",
      "vehicle_number": "KA23A9085",
      "vehicle_model": "TATA Jeep"
    },
    {
      "driver_name": "Uttam mali",
      "driver_phone": "9620011470",
      "area": "Kagwad",
      "vehicle_number": "KA710686",
      "vehicle_model": "Tata ace"
    },
    {
      "driver_name": "Adinath kerur",
      "driver_phone": "8088646969",
      "area": "UGAR khurd",
      "vehicle_number": "Ka25d1519",
      "vehicle_model": "Chevrolet Tavera"
    },
    {
      "driver_name": "Shashikant Ghatage",
      "driver_phone": "7090014949",
      "area": "Jugul",
      "vehicle_number": "MH08Z0565",
      "vehicle_model": "Tata Indica vista VX"
    },
    {
      "driver_name": "AKASH Ghorade",
      "driver_phone": "7676769090",
      "area": "Kagwad",
      "vehicle_number": "KA710680",
      "vehicle_model": "TaTa Ace 1.5 Ton Goods vehicle"
    }
  ];

  for (var data in driverData) {
    // Check if vehicle already exists to avoid duplicates
    final existing = await vehicles
        .where('vehicle_number', isEqualTo: data['vehicle_number'])
        .get();
    
    if (existing.docs.isEmpty) {
      await vehicles.add({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }
}
