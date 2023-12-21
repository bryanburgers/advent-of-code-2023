use winnow::combinator::{alt, repeat, seq, terminated};
use winnow::prelude::*;
use winnow::token::{one_of, take_while};

fn main() {
    let example = include_str!("../input.txt");
    let input = lex(example).unwrap();

    let input = parse(&input).unwrap();
    let workflows = &input.workflows;
    let mut sum = 0;
    for part in &input.part_ratings {
        let result = workflows.evaluate_part(part);
        if result {
            sum += part.sum();
        }
    }
    println!("{sum}");
}

fn parse<'a>(tokens: &[Token<'a>]) -> Result<Input<'a>, String> {
    parse_input.parse(tokens).map_err(|e| format!("{e:?}"))
}

fn lex(input: &str) -> Result<Vec<Token<'_>>, String> {
    lex_top.parse(input).map_err(|e| e.to_string())
}

fn lex_top<'a>(input: &mut &'a str) -> PResult<Vec<Token<'a>>> {
    let result = repeat(0.., lex_token).parse_next(input)?;
    let _ = repeat(0.., whitespace).parse_next(input)?;
    Ok(result)
}

fn lex_token<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    let _ = repeat(0.., whitespace).parse_next(input)?;
    alt([
        accept,
        reject,
        identifier,
        left_bracket,
        right_bracket,
        gt,
        lt,
        eq,
        colon,
        comma,
        number,
    ])
    .parse_next(input)
}

fn accept<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "A".value(Token::Accept).parse_next(input)
}

fn reject<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "R".value(Token::Reject).parse_next(input)
}

fn identifier<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    take_while(1.., |item: char| item.is_alphabetic())
        .parse_next(input)
        .map(|token| Token::Identifier(token))
}

fn left_bracket<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "{".parse_next(input).map(|_| Token::LeftBracket)
}

fn right_bracket<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "}".parse_next(input).map(|_| Token::RightBracket)
}

fn gt<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    ">".parse_next(input).map(|_| Token::Gt)
}

fn lt<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "<".parse_next(input).map(|_| Token::Lt)
}

fn eq<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "=".parse_next(input).map(|_| Token::Eq)
}

fn colon<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    ":".parse_next(input).map(|_| Token::Colon)
}

fn comma<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    ",".parse_next(input).map(|_| Token::Comma)
}

fn number<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    let number = take_while(1.., |item: char| item.is_numeric()).parse_next(input)?;
    let number = number.parse::<i32>().unwrap();
    Ok(Token::Number(number))
}

fn whitespace(input: &mut &str) -> PResult<()> {
    one_of([' ', '\t', '\r', '\n'])
        .parse_next(input)
        .map(|_| ())
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
enum Token<'a> {
    Accept,
    Reject,
    Identifier(&'a str),
    LeftBracket,
    RightBracket,
    Gt,
    Lt,
    Eq,
    Number(i32),
    Colon,
    Comma,
}

#[derive(Debug)]
struct Workflow<'a> {
    identifier: WorkflowName<'a>,
    rules: Vec<Rule<'a>>,
    otherwise: Destination<'a>,
}

impl Workflow<'_> {
    fn evaluate(&self, part: &PartRating) -> Destination<'_> {
        for rule in &self.rules {
            if rule.condition.evaluate(part) {
                return rule.destination;
            }
        }

        self.otherwise
    }
}

fn parse_workflow<'a>(input: &mut &[Token<'a>]) -> PResult<Workflow<'a>> {
    seq! {
        Workflow {
            identifier: parse_workflow_name,
            _: one_of(Token::LeftBracket),
            rules: parse_rules,
            otherwise: parse_destination,
            _: one_of(Token::RightBracket),
        }
    }
    .parse_next(input)
}

fn parse_workflow_name<'a>(input: &mut &[Token<'a>]) -> PResult<WorkflowName<'a>> {
    one_of(|item| matches!(item, Token::Identifier(_)))
        .map(|token| match token {
            Token::Identifier(i) => WorkflowName(i),
            _ => unreachable!(),
        })
        .parse_next(input)
}

#[derive(Debug)]
struct Rule<'a> {
    condition: Condition,
    destination: Destination<'a>,
}

fn parse_rules<'a>(input: &mut &[Token<'a>]) -> PResult<Vec<Rule<'a>>> {
    repeat(0.., terminated(parse_rule, one_of(Token::Comma))).parse_next(input)
}

fn parse_rule<'a>(input: &mut &[Token<'a>]) -> PResult<Rule<'a>> {
    seq! {
        Rule {
            condition: parse_condition,
            _: one_of(Token::Colon),
            destination: parse_destination,
        }
    }
    .parse_next(input)
}

#[derive(Debug)]
struct Condition {
    attribute: Attribute,
    operator: Operator,
    value: i32,
}

impl Condition {
    fn evaluate(&self, part: &PartRating) -> bool {
        let value = part.attribute(self.attribute);
        self.operator.evaluate(value, self.value)
    }
}

fn parse_condition(input: &mut &[Token<'_>]) -> PResult<Condition> {
    seq! {
        Condition {
            attribute: parse_attribute,
            operator: parse_operator,
            value: parse_number,
        }
    }
    .parse_next(input)
}

#[derive(Debug)]
struct PartRating {
    x: i32,
    m: i32,
    a: i32,
    s: i32,
}

impl PartRating {
    fn attribute(&self, attribute: Attribute) -> i32 {
        match attribute {
            Attribute::X => self.x,
            Attribute::M => self.m,
            Attribute::A => self.a,
            Attribute::S => self.s,
        }
    }

    fn sum(&self) -> i32 {
        self.x + self.m + self.a + self.s
    }
}

fn parse_part_rating<'a>(input: &mut &[Token<'a>]) -> PResult<PartRating> {
    seq! {
        PartRating {
            _: one_of(Token::LeftBracket),
            x: parse_value("x"),
            _: one_of(Token::Comma),
            m: parse_value("m"),
            _: one_of(Token::Comma),
            a: parse_value("a"),
            _: one_of(Token::Comma),
            s: parse_value("s"),
            _: one_of(Token::RightBracket),
        }
    }
    .parse_next(input)
}

fn parse_value<'a>(identifier: &'a str) -> impl FnMut(&mut &[Token<'a>]) -> PResult<i32> {
    move |input: &mut &[Token<'a>]| {
        let _ = one_of(Token::Identifier(identifier)).parse_next(input)?;
        let _ = one_of(Token::Eq).parse_next(input)?;
        let n = parse_number.parse_next(input)?;
        Ok(n)
    }
}

fn parse_number(input: &mut &[Token<'_>]) -> PResult<i32> {
    one_of(|t| matches!(t, Token::Number(_)))
        .map(|t| match t {
            Token::Number(n) => n,
            _ => unreachable!(),
        })
        .parse_next(input)
}

#[derive(Debug)]
struct Input<'a> {
    workflows: Workflows<'a>,
    part_ratings: Vec<PartRating>,
}

#[derive(Debug)]
struct Workflows<'a>(Vec<Workflow<'a>>);

impl Workflows<'_> {
    // Returns true if accepted, false if rejected
    pub fn evaluate_part(&self, part: &PartRating) -> bool {
        let mut workflow = self.find_workflow(WorkflowName("in")).unwrap();

        loop {
            match workflow.evaluate(part) {
                Destination::Workflow(name) => workflow = self.find_workflow(name).unwrap(),
                Destination::Accept => break true,
                Destination::Reject => break false,
            }
        }
    }

    pub fn find_workflow(&self, name: WorkflowName<'_>) -> Option<&Workflow<'_>> {
        self.0.iter().find(|workflow| workflow.identifier == name)
    }
}

fn parse_input<'a>(input: &mut &[Token<'a>]) -> PResult<Input<'a>> {
    seq!(Input {
        workflows: repeat(0.., parse_workflow).map(Workflows),
        part_ratings: repeat(1.., parse_part_rating),
    })
    .parse_next(input)
}

#[derive(Debug, Copy, Clone, Eq, PartialEq)]
struct WorkflowName<'a>(&'a str);

#[derive(Debug, Clone, Copy)]
enum Destination<'a> {
    Workflow(WorkflowName<'a>),
    Accept,
    Reject,
}

fn parse_destination<'a>(input: &mut &[Token<'a>]) -> PResult<Destination<'a>> {
    fn parse_accept_as_destination<'a>(input: &mut &[Token<'a>]) -> PResult<Destination<'a>> {
        one_of(Token::Accept)
            .value(Destination::Accept)
            .parse_next(input)
    }

    fn parse_reject_as_destination<'a>(input: &mut &[Token<'a>]) -> PResult<Destination<'a>> {
        one_of(Token::Reject)
            .value(Destination::Reject)
            .parse_next(input)
    }

    fn parse_workflow_name_as_destination<'a>(
        input: &mut &[Token<'a>],
    ) -> PResult<Destination<'a>> {
        parse_workflow_name
            .parse_next(input)
            .map(|workflow_name| Destination::Workflow(workflow_name))
    }

    alt([
        parse_accept_as_destination,
        parse_reject_as_destination,
        parse_workflow_name_as_destination,
    ])
    .parse_next(input)
}

#[derive(Debug, Clone, Copy)]
enum Attribute {
    X,
    M,
    A,
    S,
}

fn parse_attribute(input: &mut &[Token<'_>]) -> PResult<Attribute> {
    alt([
        one_of(Token::Identifier("x")).value(Attribute::X),
        one_of(Token::Identifier("m")).value(Attribute::M),
        one_of(Token::Identifier("a")).value(Attribute::A),
        one_of(Token::Identifier("s")).value(Attribute::S),
    ])
    .parse_next(input)
}

#[derive(Debug, Clone, Copy)]
enum Operator {
    Gt,
    Lt,
}

impl Operator {
    fn evaluate(self, left: i32, right: i32) -> bool {
        match self {
            Operator::Gt => left > right,
            Operator::Lt => left < right,
        }
    }
}

fn parse_operator(input: &mut &[Token<'_>]) -> PResult<Operator> {
    alt([
        one_of(Token::Gt).value(Operator::Gt),
        one_of(Token::Lt).value(Operator::Lt),
    ])
    .parse_next(input)
}

impl<'a> winnow::stream::ContainsToken<Token<'a>> for Token<'a> {
    fn contains_token(&self, token: Token) -> bool {
        *self == token
    }
}

impl<'a> winnow::stream::ContainsToken<Token<'a>> for &'_ [Token<'a>] {
    fn contains_token(&self, token: Token) -> bool {
        self.iter().any(|t| *t == token)
    }
}

impl<'a, const LEN: usize> winnow::stream::ContainsToken<Token<'a>> for &'_ [Token<'a>; LEN] {
    fn contains_token(&self, token: Token) -> bool {
        self.iter().any(|t| *t == token)
    }
}

impl<'a, const LEN: usize> winnow::stream::ContainsToken<Token<'a>> for [Token<'a>; LEN] {
    fn contains_token(&self, token: Token) -> bool {
        self.iter().any(|t| *t == token)
    }
}
