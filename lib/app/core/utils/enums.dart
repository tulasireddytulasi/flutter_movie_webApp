enum Gender { male, female, notAvailable }

// enum Gender {
//   male(1),
//   female(2),
//   notAvailable(-1); // Default for N/A or any other value
//
//   final int value;
//
//   const Gender(this.value);
//
//   static Gender fromValue(int val) {
//     switch (val) {
//       case 1:
//         return Gender.male;
//       case 2:
//         return Gender.female;
//       default:
//         return Gender.notAvailable;
//     }
//   }
// }