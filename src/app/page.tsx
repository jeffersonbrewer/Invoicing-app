const actions = [
  { label: "Projects", hint: "Jobs, photos and running totals" },
  { label: "Log time", hint: "Hours for you and your crew" },
  { label: "Invoices", hint: "Create and send a PDF" },
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-dvh max-w-md flex-col gap-6 p-6">
      <h1 className="text-3xl font-semibold text-[#3f6b3a]">Invoices</h1>
      <nav className="flex flex-col gap-4">
        {actions.map((a) => (
          <button
            key={a.label}
            type="button"
            className="rounded-2xl bg-white p-6 text-left shadow-sm ring-1 ring-black/5 active:scale-[0.99]"
          >
            <span className="block text-xl font-medium">{a.label}</span>
            <span className="block text-base text-gray-500">{a.hint}</span>
          </button>
        ))}
      </nav>
    </main>
  );
}
