// lib/utils/sample_data.dart
import 'dart:math';

// Add more diverse URLs for better variety
final List<String> sampleEventImages = [
  'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHwyfHxmZXN0aXZhbHxlbnwwfHx8fDE3MTQwNzQ5ODR8MA&ixlib=rb-4.0.3&q=80&w=1080', // festival
  'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHwxNnx8ZmVzdGl2YWx8ZW58MHx8fHwxNzE0MDc0OTg0fDA&ixlib=rb-4.0.3&q=80&w=1080', // concert
  'https://images.unsplash.com/photo-1519750157634-b6d47fc4f3f7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHwxNXx8c2VtaW5hcnxlbnwwfHx8fDE3MTQwNzUwMTN8MA&ixlib=rb-4.0.3&q=80&w=1080', // seminar/presentation
  'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHw5fHx3b3Jrc2hvcHxlbnwwfHx8fDE3MTQwNzUwMTN8MA&ixlib=rb-4.0.3&q=80&w=1080', // workshop
  'https://images.unsplash.com/photo-1497091071254-cc9b2ba7c48a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHw2fHx0ZWNobm9sb2d5JTIwZXZlbnR8ZW58MHx8fHwxNzE0MDc1MDMxfDA&ixlib=rb-4.0.3&q=80&w=1080', // tech event
  'https://images.unsplash.com/photo-1523580494863-6f3031224c94?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHw1fHxjYW1wdXMlMjBldmVudHxlbnwwfHx8fDE3MTQwNzUwMzF8MA&ixlib=rb-4.0.3&q=80&w=1080', // campus general
  'https://images.unsplash.com/photo-1561414927-6d86591d0c4f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHwxMXx8YWNhZGVtaWMlMjBldmVudHxlbnwwfHx8fDE3MTQwNzUwMzF8MA&ixlib=rb-4.0.3&q=80&w=1080', // academic
  'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHw0fHxjb2xsZWdlJTIwcGFydHl8ZW58MHx8fHwxNzE0MDc1MjU5fDA&ixlib=rb-4.0.3&q=80&w=1080', // party/social
  'https://images.unsplash.com/photo-1543269865-cbf427effbad?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHwzNHx8bWVldGluZ3xlbnwwfHx8fDE3MTQwNzUyODd8MA&ixlib=rb-4.0.3&q=80&w=1080', // meeting/formal
  'https://images.unsplash.com/photo-1531058020387-3be344556be6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1NzY2ODZ8MHwxfHNlYXJjaHwxfHxldmVudHxlbnwwfHx8fDE3MTQwNzUzMjV8MA&ixlib=rb-4.0.3&q=80&w=1080', // general event stage
];

String getRandomEventImageUrl() {
  final random = Random();
  return sampleEventImages[random.nextInt(sampleEventImages.length)];
}
