use std::collections::{BTreeMap, VecDeque};

mod lex;
mod parse;

fn main() {
    let input = include_str!("../input.txt");
    let ast = parse::Ast::parse(input).unwrap();
    let mut system = System::from(&ast);

    let mut observer = ScorePulseObserver::default();

    for _ in 0..1000 {
        system.press_button(&mut observer);
    }

    println!("{}", observer.score());
}

struct DisplayPulseObserver;
impl PulseObserver for DisplayPulseObserver {
    fn observe(&mut self, pulse: &SentPulse<'_>) {
        println!("{pulse:?}");
    }
}

#[derive(Default)]
struct ScorePulseObserver {
    low: usize,
    high: usize,
}

impl ScorePulseObserver {
    pub fn score(&self) -> usize {
        self.low * self.high
    }
}

impl PulseObserver for ScorePulseObserver {
    fn observe(&mut self, pulse: &SentPulse<'_>) {
        match pulse.pulse {
            Pulse::Low => self.low += 1,
            Pulse::High => self.high += 1,
        }
    }
}

#[derive(Debug)]
struct System<'a> {
    modules: BTreeMap<&'a str, Module<'a>>,
    connections: BTreeMap<&'a str, Vec<&'a str>>,
}

impl<'a> From<&parse::Ast<'a>> for System<'a> {
    fn from(value: &parse::Ast<'a>) -> Self {
        let mut modules = BTreeMap::new();
        let mut connections: BTreeMap<&'a str, Vec<&'a str>> = BTreeMap::new();
        for line in &value.lines {
            let module_name = line.source.identifier.0;
            let module: Module<'a> = match line.source.ty {
                parse::Type::None => Broadcast.into(),
                parse::Type::FlipFlop => FlipFlop::default().into(),
                parse::Type::Conjunction => Conjunction::default().into(),
            };
            modules.insert(module_name, module);
        }
        for line in &value.lines {
            let source_name = line.source.identifier.0;
            for destination in &line.destinations {
                let destination_name = destination.0;
                if let Some(destination) = modules.get_mut(destination_name) {
                    destination.attach_input(source_name);
                }
                connections
                    .entry(source_name)
                    .or_default()
                    .push(destination_name);
            }
        }
        Self {
            modules,
            connections,
        }
    }
}

impl<'a> System<'a> {
    pub fn press_button(&mut self, observer: &mut impl PulseObserver) {
        let mut queue = VecDeque::new();
        queue.push_back(SentPulse {
            from: "button",
            pulse: Pulse::Low,
            to: "broadcaster",
        });

        while let Some(pulse) = queue.pop_front() {
            observer.observe(&pulse);

            if let Some(module) = self.modules.get_mut(pulse.to) {
                if let Some(out_pulse) = module.receive(pulse.from, pulse.pulse) {
                    if let Some(destinations) = self.connections.get(pulse.to) {
                        for destination in destinations {
                            queue.push_back(SentPulse {
                                from: pulse.to,
                                pulse: out_pulse,
                                to: destination,
                            })
                        }
                    }
                }
            }
        }
    }
}

#[derive(Debug, Copy, Clone, Eq, PartialEq)]
enum Pulse {
    Low,
    High,
}

#[derive(Copy, Clone)]
struct SentPulse<'a> {
    from: &'a str,
    pulse: Pulse,
    to: &'a str,
}

impl<'a> std::fmt::Debug for SentPulse<'a> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{} {} {}",
            self.from,
            match self.pulse {
                Pulse::Low => "-low->",
                Pulse::High => "-high->",
            },
            self.to
        )
    }
}

#[derive(Debug)]
struct Broadcast;

impl Broadcast {
    pub fn receive(&mut self, _from: &str, pulse: Pulse) -> Option<Pulse> {
        Some(pulse)
    }
    pub fn attach_input(&mut self, _source: &str) {}
}

#[derive(Default, Debug)]
struct FlipFlop {
    state: bool,
}

impl FlipFlop {
    pub fn receive(&mut self, _from: &str, pulse: Pulse) -> Option<Pulse> {
        match pulse {
            Pulse::Low => {
                self.state = !self.state;
                match self.state {
                    true => Some(Pulse::High),
                    false => Some(Pulse::Low),
                }
            }
            Pulse::High => {
                // If a flip-flop module receives a high pulse, it is ignored and nothing happens
                None
            }
        }
    }
    pub fn attach_input(&mut self, _source: &str) {}
}

#[derive(Debug, Default)]
struct Conjunction<'a> {
    sources: BTreeMap<&'a str, Pulse>,
}

impl<'a> Conjunction<'a> {
    pub fn receive(&mut self, from: &'a str, pulse: Pulse) -> Option<Pulse> {
        self.sources.insert(from, pulse);
        if self.sources.values().all(|pulse| *pulse == Pulse::High) {
            Some(Pulse::Low)
        } else {
            Some(Pulse::High)
        }
    }
    pub fn attach_input(&mut self, source: &'a str) {
        self.sources.insert(source, Pulse::Low);
    }
}

#[derive(Debug)]
enum Module<'a> {
    Broadcast(Broadcast),
    FlipFlop(FlipFlop),
    Conjunction(Conjunction<'a>),
}

impl<'a> Module<'a> {
    pub fn receive(&mut self, from: &'a str, pulse: Pulse) -> Option<Pulse> {
        match self {
            Module::Broadcast(module) => module.receive(from, pulse),
            Module::FlipFlop(module) => module.receive(from, pulse),
            Module::Conjunction(module) => module.receive(from, pulse),
        }
    }

    pub fn attach_input(&mut self, source: &'a str) {
        match self {
            Module::Broadcast(module) => module.attach_input(source),
            Module::FlipFlop(module) => module.attach_input(source),
            Module::Conjunction(module) => module.attach_input(source),
        }
    }
}

impl<'a> From<Broadcast> for Module<'a> {
    fn from(value: Broadcast) -> Self {
        Module::Broadcast(value)
    }
}

impl<'a> From<FlipFlop> for Module<'a> {
    fn from(value: FlipFlop) -> Self {
        Module::FlipFlop(value)
    }
}

impl<'a> From<Conjunction<'a>> for Module<'a> {
    fn from(value: Conjunction<'a>) -> Self {
        Module::Conjunction(value)
    }
}

trait PulseObserver {
    fn observe(&mut self, pulse: &SentPulse<'_>);
}
