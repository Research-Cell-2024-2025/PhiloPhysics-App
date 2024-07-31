sortMap(Map data, String valName){
   var sortedEntries = data.entries.toList()
        ..sort((e1, e2) {
          return e1.value[valName].compareTo(e2.value[valName]);
        });

      Map data1 = Map();

      for (int i = 0; i < sortedEntries.length; i++)
        data1.putIfAbsent(sortedEntries[i].key, () => sortedEntries[i].value);
      return data1;
}