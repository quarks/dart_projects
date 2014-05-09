part of collision_clones;

num randomNum(num max) => new Random().nextDouble() * max;
int randomInt(int max) => new Random().nextInt(max);
randomListElement(List list) => list[randomInt(list.length - 1)];
