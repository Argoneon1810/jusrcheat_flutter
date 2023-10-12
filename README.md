# jusrcheat_flutter
flutter port of [jusrcheat](https://github.com/xperia64/Jusrcheat)

# Changes
1. if private field has both getter and setter, it is changed into public field.
   - except for the field that has getter implemented due to interface
2. since dart does not support method overloading, unnamed constructors are not separate names.
3. better understandable names
   - usually they are:
     - delete -> remove
     - postfix 'At' applied to methods that used specific index to modify list member.
     - add -> append if adding member at the tail of the list
     - toByte -> serialize
     - etc...

# Issue
1. Writing file should be asking where to save and what name it should be using, but it doesn't. (Windows)
2. Parsed copy is not showing korean font, though it is well shown when saved.
3. On Android, app crashes when coming back from file selector
