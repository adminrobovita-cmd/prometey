
import {
  Activity,
  AlertTriangle,
  Bell,
  Building2,
  CheckCircle2,
  ChevronDown,
  Cpu,
  Factory,
  Gauge,
  LayoutDashboard,
  Radio,
  Search,
  Settings,
  ShieldCheck,
  Thermometer,
  Users,
  Wifi,
  WifiOff,
  Clock3,
} from "lucide-react";

import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import "./App.css";

const workshops = [
  { id: "01", name: "Цех №1", temp: 22.4, min: 18, max: 25, status: "normal", sensor: "TEMP-001" },
  { id: "02", name: "Цех №2", temp: 24.8, min: 18, max: 25, status: "warning", sensor: "TEMP-002" },
  { id: "03", name: "Цех №3", temp: 21.6, min: 18, max: 25, status: "normal", sensor: "TEMP-003" },
  { id: "04", name: "Цех №4", temp: 19.2, min: 18, max: 25, status: "normal", sensor: "TEMP-004" },
  { id: "05", name: "Цех №5", temp: 27.3, min: 18, max: 25, status: "critical", sensor: "TEMP-005" },
  { id: "06", name: "Цех №6", temp: 22.1, min: 18, max: 25, status: "normal", sensor: "TEMP-006" },
];

const temperatureHistory = [
  { time: "08:00", temperature: 20.2 },
  { time: "09:00", temperature: 20.8 },
  { time: "10:00", temperature: 21.3 },
  { time: "11:00", temperature: 22.1 },
  { time: "12:00", temperature: 23.4 },
  { time: "13:00", temperature: 22.8 },
  { time: "14:00", temperature: 23.1 },
  { time: "15:00", temperature: 22.4 },
];

const navigation = [
  { label: "Главная", icon: LayoutDashboard },
  { label: "Цеха", icon: Building2 },
  { label: "Оборудование", icon: Cpu },
  { label: "История измерений", icon: Activity },
  { label: "Аварии и события", icon: AlertTriangle },
  { label: "Пользователи", icon: Users },
];

function App() {
  return (
    <div className="app">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-icon">
            <Thermometer size={25} />
          </div>
          <div>
            <div className="brand-name">ПРОМЕТЕЙ</div>
            <div className="brand-subtitle">INDUSTRIAL MONITORING</div>
          </div>
        </div>

        <div className="nav-caption">ОСНОВНОЕ МЕНЮ</div>

        <nav className="navigation">
          {navigation.map((item, index) => {
            const Icon = item.icon;

            return (
              <button
                className={`nav-item ${index === 0 ? "active" : ""}`}
                key={item.label}
              >
                <Icon size={19} />
                <span>{item.label}</span>
                {item.label === "Аварии и события" && (
                  <span className="nav-counter">2</span>
                )}
              </button>
            );
          })}
        </nav>

        <div className="nav-caption settings-caption">СИСТЕМА</div>

        <button className="nav-item">
          <Settings size={19} />
          <span>Настройки</span>
        </button>

        <div className="sidebar-bottom">
          <div className="connection-card">
            <div className="connection-title">
              <span className="connection-dot" />
              Тестовый режим
            </div>
            <div className="connection-description">
              Используются демонстрационные данные
            </div>
          </div>

          <div className="user-profile">
            <div className="user-avatar">А</div>
            <div className="user-info">
              <strong>Администратор</strong>
              <span>Системный администратор</span>
            </div>
            <ChevronDown size={17} />
          </div>
        </div>
      </aside>

      <main className="main-content">
        <header className="topbar">
          <div className="breadcrumb">
            Предприятие <span>/</span> <strong>Главная панель</strong>
          </div>

          <div className="topbar-right">
            <div className="system-status">
              <span className="connection-dot" />
              Система активна
            </div>

            <button className="icon-button" aria-label="Поиск">
              <Search size={19} />
            </button>

            <button className="icon-button notification-button" aria-label="Уведомления">
              <Bell size={19} />
              <span />
            </button>

            <div className="topbar-date">17 ноября 2026</div>
          </div>
        </header>

        <div className="dashboard">
          <div className="page-heading">
            <div>
              <div className="eyebrow">МОНИТОРИНГ ПРЕДПРИЯТИЯ</div>
              <h1>Главная панель</h1>
              <p>Общая информация о состоянии температурного режима предприятия</p>
            </div>

            <button className="period-button">
              <Clock3 size={17} />
              Последние 24 часа
              <ChevronDown size={16} />
            </button>
          </div>

          <section className="metrics-grid">
            <div className="metric-card">
              <div className="metric-top">
                <span>Всего цехов</span>
                <div className="metric-icon blue">
                  <Factory size={21} />
                </div>
              </div>
              <div className="metric-value">15</div>
              <div className="metric-footer">
                <span className="positive">15 активных</span>
                <span>на предприятии</span>
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-top">
                <span>Средняя температура</span>
                <div className="metric-icon cyan">
                  <Thermometer size={21} />
                </div>
              </div>
              <div className="metric-value">22.4<span>°C</span></div>
              <div className="metric-footer">
                <span className="positive">В пределах нормы</span>
                <span>по предприятию</span>
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-top">
                <span>Оборудование</span>
                <div className="metric-icon green">
                  <Cpu size={21} />
                </div>
              </div>
              <div className="metric-value">18<span>/20</span></div>
              <div className="metric-footer">
                <span className="positive">90% доступно</span>
                <span>контроллеров</span>
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-top">
                <span>Активные аварии</span>
                <div className="metric-icon red">
                  <AlertTriangle size={21} />
                </div>
              </div>
              <div className="metric-value">2</div>
              <div className="metric-footer">
                <span className="negative">Требуют внимания</span>
                <span>события</span>
              </div>
            </div>
          </section>

          <section className="content-grid">
            <div className="panel chart-panel">
              <div className="panel-heading">
                <div>
                  <h2>Температурная динамика</h2>
                  <p>Средняя температура предприятия</p>
                </div>
                <span className="chart-badge">°C</span>
              </div>

              <div className="chart-container">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={temperatureHistory}>
                    <defs>
                      <linearGradient id="temperatureGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#38bdf8" stopOpacity={0.25} />
                        <stop offset="95%" stopColor="#38bdf8" stopOpacity={0} />
                      </linearGradient>
                    </defs>

                    <CartesianGrid stroke="#26364a" strokeDasharray="4 4" vertical={false} />

                    <XAxis
                      dataKey="time"
                      stroke="#75869b"
                      tickLine={false}
                      axisLine={false}
                      tick={{ fontSize: 12 }}
                    />

                    <YAxis
                      stroke="#75869b"
                      tickLine={false}
                      axisLine={false}
                      tick={{ fontSize: 12 }}
                      domain={[15, 30]}
                    />

                    <Tooltip
                      contentStyle={{
                        background: "#172438",
                        border: "1px solid #33445a",
                        borderRadius: 8,
                        color: "#ffffff",
                      }}
                      formatter={(value) => [`${value} °C`, "Температура"]}
                    />

                    <Area
                      type="monotone"
                      dataKey="temperature"
                      stroke="#38bdf8"
                      strokeWidth={2.5}
                      fill="url(#temperatureGradient)"
                      dot={false}
                      activeDot={{ r: 5, fill: "#38bdf8" }}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>

              <div className="chart-footer">
                <span><i className="legend-dot" /> Средняя температура</span>
                <span>Обновление: демонстрационные данные</span>
              </div>
            </div>

            <div className="panel equipment-panel">
              <div className="panel-heading">
                <div>
                  <h2>Состояние системы</h2>
                  <p>Инфраструктура мониторинга</p>
                </div>
                <Gauge size={21} className="heading-icon" />
              </div>

              <div className="system-item">
                <div className="system-item-icon green">
                  <Radio size={19} />
                </div>
                <div className="system-item-info">
                  <strong>MQTT Broker</strong>
                  <span>Транспорт телеметрии</span>
                </div>
                <span className="status-label online">Активен</span>
              </div>

              <div className="system-item">
                <div className="system-item-icon green">
                  <Wifi size={19} />
                </div>
                <div className="system-item-info">
                  <strong>Сеть устройств</strong>
                  <span>Подключение контроллеров</span>
                </div>
                <span className="status-label online">Активна</span>
              </div>

              <div className="system-item">
                <div className="system-item-icon blue">
                  <ShieldCheck size={19} />
                </div>
                <div className="system-item-info">
                  <strong>Backend API</strong>
                  <span>Обработка данных</span>
                </div>
                <span className="status-label demo">Демо</span>
              </div>

              <div className="system-item">
                <div className="system-item-icon blue">
                  <WifiOff size={19} />
                </div>
                <div className="system-item-info">
                  <strong>Внешние подключения</strong>
                  <span>Не настроены</span>
                </div>
                <span className="status-label demo">Ожидание</span>
              </div>

              <div className="system-note">
                <CheckCircle2 size={17} />
                Демонстрационная конфигурация загружена
              </div>
            </div>
          </section>

          <section className="panel workshops-panel">
            <div className="panel-heading">
              <div>
                <h2>Состояние цехов</h2>
                <p>Текущие температурные показатели</p>
              </div>
              <button className="text-button">
                Все цеха <span>→</span>
              </button>
            </div>

            <div className="workshop-table">
              <div className="table-header">
                <span>ЦЕХ</span>
                <span>ДАТЧИК</span>
                <span>ТЕМПЕРАТУРА</span>
                <span>НОРМАТИВ</span>
                <span>СОСТОЯНИЕ</span>
              </div>

              {workshops.map((workshop) => (
                <div className="table-row" key={workshop.id}>
                  <strong>{workshop.name}</strong>
                  <span className="sensor-name">{workshop.sensor}</span>
                  <strong className="temperature-value">
                    {workshop.temp.toFixed(1)} °C
                  </strong>
                  <span className="norm-value">
                    {workshop.min}–{workshop.max} °C
                  </span>
                  <span className={`status-label ${workshop.status}`}>
                    <span className="status-dot" />
                    {workshop.status === "normal"
                      ? "Норма"
                      : workshop.status === "warning"
                      ? "Предупреждение"
                      : "Критично"}
                  </span>
                </div>
              ))}
            </div>
          </section>

          <footer className="dashboard-footer">
            <span>ПРОМЕТЕЙ · Система промышленного мониторинга</span>
            <span>Версия 0.1.0 · Тестовая среда</span>
          </footer>
        </div>
      </main>
    </div>
  );
}

export default App;
